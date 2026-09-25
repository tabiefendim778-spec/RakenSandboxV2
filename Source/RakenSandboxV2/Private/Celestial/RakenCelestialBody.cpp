#include "Celestial/RakenCelestialBody.h"

#include "Components/StaticMeshComponent.h"
#include "Components/PointLightComponent.h"
#include "Materials/MaterialInstanceDynamic.h"
#include "Engine/StaticMesh.h"
#include "Simulation/RakenSimulationSubsystem.h"
#include "UObject/ConstructorHelpers.h"

ARakenCelestialBody::ARakenCelestialBody()
{
    PrimaryActorTick.bCanEverTick = true;

    BodyMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("BodyMesh"));
    RootComponent = BodyMesh;

    StarLight = CreateDefaultSubobject<UPointLightComponent>(TEXT("StarLight"));
    StarLight->SetupAttachment(BodyMesh);
    StarLight->SetVisibility(false);
    StarLight->SetCastShadows(true);
    StarLight->SetAttenuationRadius(100000000.0f);

    static ConstructorHelpers::FObjectFinder<UStaticMesh> SphereMesh(
        TEXT("/Engine/BasicShapes/Sphere.Sphere"));

    if (SphereMesh.Succeeded())
    {
        BodyMesh->SetStaticMesh(SphereMesh.Object);
    }

    BodyMesh->SetCollisionEnabled(ECollisionEnabled::QueryOnly);
    BodyMesh->SetCollisionResponseToAllChannels(ECR_Ignore);
    BodyMesh->SetCollisionResponseToChannel(ECC_Visibility, ECR_Block);

    if (UMaterialInterface* BaseMaterial = BodyMesh->GetMaterial(0))
    {
        DynamicMaterial = UMaterialInstanceDynamic::Create(BaseMaterial, this);
        if (DynamicMaterial)
        {
            BodyMesh->SetMaterial(0, DynamicMaterial);
        }
    }
}

void ARakenCelestialBody::BindToState(const FRakenCelestialState& State)
{
    BodyId = State.Id;
    ApplyState(State);
}

bool ARakenCelestialBody::GetCurrentState(FRakenCelestialState& OutState) const
{
    if (!BodyId.IsValid() || !GetWorld())
    {
        return false;
    }

    if (const URakenSimulationSubsystem* Simulation =
        GetWorld()->GetSubsystem<URakenSimulationSubsystem>())
    {
        return Simulation->GetBody(BodyId, OutState);
    }

    return false;
}

void ARakenCelestialBody::Tick(const float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);

    if (!BodyId.IsValid())
    {
        return;
    }

    if (URakenSimulationSubsystem* Simulation = GetWorld()->GetSubsystem<URakenSimulationSubsystem>())
    {
        FRakenCelestialState State;
        if (Simulation->GetBody(BodyId, State))
        {
            ApplyState(State);
        }
        else
        {
            Destroy();
        }
    }
}

void ARakenCelestialBody::ApplyState(const FRakenCelestialState& State)
{
    const URakenSimulationSubsystem* Simulation =
        GetWorld()->GetSubsystem<URakenSimulationSubsystem>();

    if (!Simulation)
    {
        return;
    }

    SetActorLocation(State.PositionMeters * Simulation->PositionCentimetersPerMeter);

    const double VisualRadiusCm = ComputeVisualRadiusCm(State);
    const double EngineSphereRadiusCm = 50.0;
    const double UniformScale = VisualRadiusCm / EngineSphereRadiusCm;

    BodyMesh->SetWorldScale3D(FVector(UniformScale));

    if (DynamicMaterial)
    {
        DynamicMaterial->SetVectorParameterValue(TEXT("Color"), State.BaseColor);
        DynamicMaterial->SetVectorParameterValue(TEXT("BaseColor"), State.BaseColor);
    }

    const bool bIsStar =
        State.Type == ERakenCelestialType::Star ||
        State.Type == ERakenCelestialType::NeutronStar;

    StarLight->SetVisibility(bIsStar);

    if (bIsStar)
    {
        StarLight->SetLightColor(State.BaseColor);
        const double SolarMasses = FMath::Max(State.MassKg / 1.98847e30, 0.01);
        const float Intensity = static_cast<float>(150000.0 * FMath::Pow(SolarMasses, 0.75));
        StarLight->SetIntensity(Intensity);
    }
}

double ARakenCelestialBody::ComputeVisualRadiusCm(const FRakenCelestialState& State) const
{
    const double SafeRadius = FMath::Max(State.RadiusMeters, 1.0);
    const double LogRadius = FMath::LogX(10.0, SafeRadius);
    const double VisualRadius = 10.0 * LogRadius * LogRadius;

    return FMath::Clamp(
        VisualRadius,
        MinimumVisualRadiusCm,
        MaximumVisualRadiusCm);
}
