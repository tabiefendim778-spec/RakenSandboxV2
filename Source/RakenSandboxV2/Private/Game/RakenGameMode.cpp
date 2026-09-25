#include "Game/RakenGameMode.h"

#include "Celestial/RakenCelestialBody.h"
#include "Celestial/RakenCelestialTypes.h"
#include "Engine/Engine.h"
#include "GameFramework/PlayerController.h"
#include "Player/RakenSpacePawn.h"
#include "Player/RakenPlayerController.h"
#include "UI/RakenHUD.h"
#include "Simulation/RakenSimulationSubsystem.h"
#include "Settings/RakenGraphicsSettings.h"
#include "Rendering/RakenStarfield.h"
#include "GenericPlatform/GenericPlatformMisc.h"

ARakenGameMode::ARakenGameMode()
{
    DefaultPawnClass = ARakenSpacePawn::StaticClass();
    PlayerControllerClass = ARakenPlayerController::StaticClass();
    HUDClass = ARakenHUD::StaticClass();
}

void ARakenGameMode::BeginPlay()
{
    Super::BeginPlay();
    const FString GPUBrand = FPlatformMisc::GetPrimaryGPUBrand();
    if (GPUBrand.Contains(TEXT("Intel"), ESearchCase::IgnoreCase))
    {
        URakenGraphicsSettings::ApplyQualityPreset(ERakenQualityPreset::Compatibility);
    }
    else
    {
        URakenGraphicsSettings::ApplyQualityPreset(ERakenQualityPreset::High);
    }

    BootstrapSolarSystem();

    GetWorld()->SpawnActor<ARakenStarfield>(
        ARakenStarfield::StaticClass(),
        FVector::ZeroVector,
        FRotator::ZeroRotator);

    if (GEngine)
    {
        GEngine->AddOnScreenDebugMessage(
            -1,
            8.0f,
            FColor::Cyan,
            TEXT("RAKEN SANDBOX V2 | N-body core active"));
    }
}

void ARakenGameMode::BootstrapSolarSystem()
{
    URakenSimulationSubsystem* Simulation =
        GetWorld()->GetSubsystem<URakenSimulationSubsystem>();

    if (!Simulation)
    {
        return;
    }

    Simulation->ClearBodies();
    Simulation->TimeScale = 3600.0;
    Simulation->FixedStepSeconds = 60.0;

    FRakenCelestialState Sun;
    Sun.DisplayName = TEXT("Sun");
    Sun.Type = ERakenCelestialType::Star;
    Sun.MassKg = 1.98847e30;
    Sun.RadiusMeters = 6.957e8;
    Sun.PositionMeters = FVector::ZeroVector;
    Sun.VelocityMetersPerSecond = FVector::ZeroVector;
    Sun.SurfaceTemperatureKelvin = 5772.0;
    Sun.BaseColor = FLinearColor(1.0f, 0.72f, 0.30f);
    Sun.bFixed = true;

    FRakenCelestialState Earth;
    Earth.DisplayName = TEXT("Earth");
    Earth.Type = ERakenCelestialType::Planet;
    Earth.MassKg = 5.9722e24;
    Earth.RadiusMeters = 6.371e6;
    Earth.PositionMeters = FVector(1.495978707e11, 0.0, 0.0);
    Earth.VelocityMetersPerSecond = FVector(0.0, 29780.0, 0.0);
    Earth.SurfaceTemperatureKelvin = 288.0;
    Earth.BaseColor = FLinearColor(0.10f, 0.35f, 1.0f);

    FRakenCelestialState Moon;
    Moon.DisplayName = TEXT("Moon");
    Moon.Type = ERakenCelestialType::Moon;
    Moon.MassKg = 7.342e22;
    Moon.RadiusMeters = 1.7374e6;
    Moon.PositionMeters = Earth.PositionMeters + FVector(3.844e8, 0.0, 0.0);
    Moon.VelocityMetersPerSecond =
        Earth.VelocityMetersPerSecond + FVector(0.0, 1022.0, 0.0);
    Moon.SurfaceTemperatureKelvin = 250.0;
    Moon.BaseColor = FLinearColor(0.58f, 0.60f, 0.64f);

    const FGuid SunId = Simulation->AddBody(Sun);
    const FGuid EarthId = Simulation->AddBody(Earth);
    const FGuid MoonId = Simulation->AddBody(Moon);

    const FGuid Ids[] = { SunId, EarthId, MoonId };
    for (const FGuid& Id : Ids)
    {
        FRakenCelestialState State;
        if (!Simulation->GetBody(Id, State))
        {
            continue;
        }

        ARakenCelestialBody* Actor =
            GetWorld()->SpawnActor<ARakenCelestialBody>(
                ARakenCelestialBody::StaticClass(),
                FVector::ZeroVector,
                FRotator::ZeroRotator);

        if (Actor)
        {
            Actor->BindToState(State);
            SpawnedBodies.Add(Actor);
        }
    }

    if (APawn* Pawn = GetWorld()->GetFirstPlayerController()
        ? GetWorld()->GetFirstPlayerController()->GetPawn()
        : nullptr)
    {
        Pawn->SetActorLocation(FVector(-250000.0, -250000.0, 120000.0));
        Pawn->SetActorRotation(FRotator(-12.0, 45.0, 0.0));
    }
}
