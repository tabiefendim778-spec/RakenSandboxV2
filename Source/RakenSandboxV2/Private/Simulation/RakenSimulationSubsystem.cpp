#include "Simulation/RakenSimulationSubsystem.h"
#include "Physics/RakenPhysics.h"

TStatId URakenSimulationSubsystem::GetStatId() const
{
    RETURN_QUICK_DECLARE_CYCLE_STAT(URakenSimulationSubsystem, STATGROUP_Tickables);
}

FGuid URakenSimulationSubsystem::AddBody(const FRakenCelestialState& State)
{
    FRakenCelestialState Copy = State;
    if (!Copy.Id.IsValid())
    {
        Copy.Id = FGuid::NewGuid();
    }

    Bodies.Add(Copy);
    return Copy.Id;
}

bool URakenSimulationSubsystem::RemoveBody(const FGuid Id)
{
    const int32 Index = Bodies.IndexOfByPredicate([&](const FRakenCelestialState& Body)
    {
        return Body.Id == Id;
    });

    if (Index == INDEX_NONE)
    {
        return false;
    }

    Bodies.RemoveAtSwap(Index);
    return true;
}

void URakenSimulationSubsystem::ClearBodies()
{
    Bodies.Reset();
    AccumulatorSeconds = 0.0;
}

bool URakenSimulationSubsystem::GetBody(const FGuid Id, FRakenCelestialState& OutState) const
{
    const FRakenCelestialState* Found = Bodies.FindByPredicate([&](const FRakenCelestialState& Body)
    {
        return Body.Id == Id;
    });

    if (!Found)
    {
        return false;
    }

    OutState = *Found;
    return true;
}

void URakenSimulationSubsystem::Tick(const float DeltaTime)
{
    if (Bodies.Num() == 0 || FixedStepSeconds <= 0.0 || TimeScale <= 0.0)
    {
        return;
    }

    AccumulatorSeconds += static_cast<double>(DeltaTime) * TimeScale;

    int32 Substeps = 0;
    while (AccumulatorSeconds >= FixedStepSeconds && Substeps < MaxSubstepsPerFrame)
    {
        StepSimulation(FixedStepSeconds);
        AccumulatorSeconds -= FixedStepSeconds;
        ++Substeps;
    }

    if (Substeps == MaxSubstepsPerFrame)
    {
        AccumulatorSeconds = FMath::Min(AccumulatorSeconds, FixedStepSeconds);
    }
}

void URakenSimulationSubsystem::CalculateAccelerations(TArray<FVector>& OutAccelerations) const
{
    OutAccelerations.Init(FVector::ZeroVector, Bodies.Num());

    for (int32 A = 0; A < Bodies.Num(); ++A)
    {
        for (int32 B = A + 1; B < Bodies.Num(); ++B)
        {
            const FVector Delta = Bodies[B].PositionMeters - Bodies[A].PositionMeters;

            OutAccelerations[A] += RakenPhysics::AccelerationFromPointMass(
                Delta,
                Bodies[B].MassKg,
                SofteningMeters);

            OutAccelerations[B] += RakenPhysics::AccelerationFromPointMass(
                -Delta,
                Bodies[A].MassKg,
                SofteningMeters);
        }
    }
}

void URakenSimulationSubsystem::StepSimulation(const double StepSeconds)
{
    TArray<FVector> InitialAccelerations;
    CalculateAccelerations(InitialAccelerations);

    const double HalfStep = 0.5 * StepSeconds;
    const double HalfStepSquared = 0.5 * StepSeconds * StepSeconds;

    for (int32 Index = 0; Index < Bodies.Num(); ++Index)
    {
        FRakenCelestialState& Body = Bodies[Index];
        if (Body.bFixed)
        {
            continue;
        }

        Body.PositionMeters += Body.VelocityMetersPerSecond * StepSeconds
            + InitialAccelerations[Index] * HalfStepSquared;

        Body.VelocityMetersPerSecond += InitialAccelerations[Index] * HalfStep;
    }

    TArray<FVector> FinalAccelerations;
    CalculateAccelerations(FinalAccelerations);

    for (int32 Index = 0; Index < Bodies.Num(); ++Index)
    {
        if (!Bodies[Index].bFixed)
        {
            Bodies[Index].VelocityMetersPerSecond += FinalAccelerations[Index] * HalfStep;
        }
    }

    ResolveCollisions();
}

void URakenSimulationSubsystem::ResolveCollisions()
{
    for (int32 A = 0; A < Bodies.Num(); ++A)
    {
        for (int32 B = Bodies.Num() - 1; B > A; --B)
        {
            const double CollisionDistance = Bodies[A].RadiusMeters + Bodies[B].RadiusMeters;
            const double DistanceSquared = FVector::DistSquared(
                Bodies[A].PositionMeters,
                Bodies[B].PositionMeters);

            if (DistanceSquared > CollisionDistance * CollisionDistance)
            {
                continue;
            }

            FRakenCelestialState& Primary = Bodies[A];
            const FRakenCelestialState Secondary = Bodies[B];

            const double TotalMass = Primary.MassKg + Secondary.MassKg;
            if (TotalMass <= 0.0)
            {
                Bodies.RemoveAtSwap(B);
                continue;
            }

            Primary.PositionMeters =
                (Primary.PositionMeters * Primary.MassKg + Secondary.PositionMeters * Secondary.MassKg)
                / TotalMass;

            Primary.VelocityMetersPerSecond =
                (Primary.VelocityMetersPerSecond * Primary.MassKg
                    + Secondary.VelocityMetersPerSecond * Secondary.MassKg)
                / TotalMass;

            Primary.RadiusMeters = FMath::Pow(
                FMath::Pow(Primary.RadiusMeters, 3.0)
                    + FMath::Pow(Secondary.RadiusMeters, 3.0),
                1.0 / 3.0);

            Primary.MassKg = TotalMass;
            Primary.bFixed = Primary.bFixed || Secondary.bFixed;

            Bodies.RemoveAtSwap(B);
        }
    }
}
