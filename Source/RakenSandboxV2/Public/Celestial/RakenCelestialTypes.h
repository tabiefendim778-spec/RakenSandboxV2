#pragma once

#include "CoreMinimal.h"
#include "RakenCelestialTypes.generated.h"

UENUM(BlueprintType)
enum class ERakenCelestialType : uint8
{
    Planet,
    Moon,
    Star,
    NeutronStar,
    BlackHole,
    Comet,
    Asteroid
};

USTRUCT(BlueprintType)
struct RAKENSANDBOXV2_API FRakenCelestialState
{
    GENERATED_BODY()

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Identity")
    FGuid Id;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Identity")
    FName DisplayName = NAME_None;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Identity")
    ERakenCelestialType Type = ERakenCelestialType::Planet;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Physics", meta=(ClampMin="0.0"))
    double MassKg = 1.0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Physics", meta=(ClampMin="0.0"))
    double RadiusMeters = 1.0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Physics")
    FVector PositionMeters = FVector::ZeroVector;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Physics")
    FVector VelocityMetersPerSecond = FVector::ZeroVector;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Physics")
    bool bFixed = false;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Appearance")
    FLinearColor BaseColor = FLinearColor::White;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Appearance", meta=(ClampMin="0.0"))
    double SurfaceTemperatureKelvin = 288.0;

    FRakenCelestialState()
        : Id(FGuid::NewGuid())
    {
    }
};
