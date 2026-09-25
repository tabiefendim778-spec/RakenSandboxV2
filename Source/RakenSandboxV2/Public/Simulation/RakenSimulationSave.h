#pragma once

#include "CoreMinimal.h"
#include "Celestial/RakenCelestialTypes.h"
#include "RakenSimulationSave.generated.h"

USTRUCT()
struct RAKENSANDBOXV2_API FRakenSimulationSnapshot
{
    GENERATED_BODY()

    UPROPERTY()
    TArray<FRakenCelestialState> Bodies;

    UPROPERTY()
    double TimeScale = 3600.0;

    UPROPERTY()
    double FixedStepSeconds = 60.0;

    UPROPERTY()
    bool bPaused = false;
};
