#pragma once

#include "CoreMinimal.h"

namespace RakenPhysics
{
    constexpr double GravitationalConstant = 6.67430e-11;

    inline FVector AccelerationFromPointMass(
        const FVector& DeltaMeters,
        const double SourceMassKg,
        const double SofteningMeters)
    {
        const double SofteningSquared = SofteningMeters * SofteningMeters;
        const double DistanceSquared = FMath::Max(DeltaMeters.SizeSquared() + SofteningSquared, 1.0);
        const double InverseDistance = 1.0 / FMath::Sqrt(DistanceSquared);
        const double InverseDistanceCubed = InverseDistance * InverseDistance * InverseDistance;
        return DeltaMeters * (GravitationalConstant * SourceMassKg * InverseDistanceCubed);
    }
}
