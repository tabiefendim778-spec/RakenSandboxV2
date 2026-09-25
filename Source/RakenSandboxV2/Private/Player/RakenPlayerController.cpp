#include "Player/RakenPlayerController.h"

#include "Celestial/RakenCelestialBody.h"
#include "Celestial/RakenBlackHoleBody.h"
#include "EngineUtils.h"
#include "GameFramework/Pawn.h"
#include "Simulation/RakenSimulationSubsystem.h"
#include "UI/RakenHUD.h"

ARakenPlayerController::ARakenPlayerController()
{
    bShowMouseCursor = true;
    bEnableClickEvents = true;
    bEnableMouseOverEvents = true;
}

void ARakenPlayerController::SetupInputComponent()
{
    Super::SetupInputComponent();

    if (InputComponent)
    {
        InputComponent->BindAction(
            TEXT("Select"),
            IE_Pressed,
            this,
            &ARakenPlayerController::SelectUnderCursor);

        InputComponent->BindAction(TEXT("PauseSimulation"), IE_Pressed, this, &ARakenPlayerController::TogglePause);
        InputComponent->BindAction(TEXT("FasterTime"), IE_Pressed, this, &ARakenPlayerController::FasterTime);
        InputComponent->BindAction(TEXT("SlowerTime"), IE_Pressed, this, &ARakenPlayerController::SlowerTime);
        InputComponent->BindAction(TEXT("SpawnPlanet"), IE_Pressed, this, &ARakenPlayerController::SpawnPlanetPreset);
        InputComponent->BindAction(TEXT("SpawnStar"), IE_Pressed, this, &ARakenPlayerController::SpawnStarPreset);
        InputComponent->BindAction(TEXT("SpawnBlackHole"), IE_Pressed, this, &ARakenPlayerController::SpawnBlackHolePreset);
        InputComponent->BindAction(TEXT("SpawnMoon"), IE_Pressed, this, &ARakenPlayerController::SpawnMoonPreset);
        InputComponent->BindAction(TEXT("QuickSave"), IE_Pressed, this, &ARakenPlayerController::QuickSave);
        InputComponent->BindAction(TEXT("QuickLoad"), IE_Pressed, this, &ARakenPlayerController::QuickLoad);
        InputComponent->BindAction(TEXT("ToggleSizeComparison"), IE_Pressed, this, &ARakenPlayerController::ToggleSizeComparison);
    }
}

void ARakenPlayerController::ClearSelection()
{
    SelectedBody = nullptr;
}

void ARakenPlayerController::SelectUnderCursor()
{
    FHitResult Hit;

    if (!GetHitResultUnderCursor(ECC_Visibility, true, Hit))
    {
        ClearSelection();
        return;
    }

    SelectedBody = Cast<ARakenCelestialBody>(Hit.GetActor());
}

void ARakenPlayerController::TogglePause()
{
    if (URakenSimulationSubsystem* Simulation = GetWorld()->GetSubsystem<URakenSimulationSubsystem>())
    {
        Simulation->bPaused = !Simulation->bPaused;
    }
}

void ARakenPlayerController::FasterTime()
{
    if (URakenSimulationSubsystem* Simulation = GetWorld()->GetSubsystem<URakenSimulationSubsystem>())
    {
        Simulation->TimeScale = FMath::Clamp(Simulation->TimeScale * 2.0, 0.25, 1.0e8);
    }
}

void ARakenPlayerController::SlowerTime()
{
    if (URakenSimulationSubsystem* Simulation = GetWorld()->GetSubsystem<URakenSimulationSubsystem>())
    {
        Simulation->TimeScale = FMath::Clamp(Simulation->TimeScale * 0.5, 0.25, 1.0e8);
    }
}

void ARakenPlayerController::SpawnPlanetPreset()
{
    SpawnPreset(ERakenCelestialType::Planet);
}

void ARakenPlayerController::SpawnStarPreset()
{
    SpawnPreset(ERakenCelestialType::Star);
}

void ARakenPlayerController::SpawnBlackHolePreset()
{
    SpawnPreset(ERakenCelestialType::BlackHole);
}

void ARakenPlayerController::SpawnMoonPreset()
{
    SpawnPreset(ERakenCelestialType::Moon);
}

void ARakenPlayerController::SpawnPreset(const ERakenCelestialType Type)
{
    URakenSimulationSubsystem* Simulation =
        GetWorld() ? GetWorld()->GetSubsystem<URakenSimulationSubsystem>() : nullptr;

    APawn* Pawn = GetPawn();

    if (!Simulation || !Pawn || Simulation->PositionCentimetersPerMeter <= 0.0)
    {
        return;
    }

    const FVector SpawnWorld =
        Pawn->GetActorLocation() + Pawn->GetActorForwardVector() * 75000.0;

    FRakenCelestialState State;
    State.PositionMeters = SpawnWorld / Simulation->PositionCentimetersPerMeter;
    State.VelocityMetersPerSecond = FVector::ZeroVector;
    State.Type = Type;

    switch (Type)
    {
        case ERakenCelestialType::Planet:
            State.DisplayName = TEXT("New Planet");
            State.MassKg = 5.9722e24;
            State.RadiusMeters = 6.371e6;
            State.SurfaceTemperatureKelvin = 288.0;
            State.BaseColor = FLinearColor(0.08f, 0.32f, 0.95f);
            break;

        case ERakenCelestialType::Moon:
            State.DisplayName = TEXT("New Moon");
            State.MassKg = 7.342e22;
            State.RadiusMeters = 1.7374e6;
            State.SurfaceTemperatureKelvin = 250.0;
            State.BaseColor = FLinearColor(0.58f, 0.60f, 0.64f);
            break;

        case ERakenCelestialType::Star:
            State.DisplayName = TEXT("New Star");
            State.MassKg = 1.98847e30;
            State.RadiusMeters = 6.957e8;
            State.SurfaceTemperatureKelvin = 5772.0;
            State.BaseColor = FLinearColor(1.0f, 0.72f, 0.28f);
            break;

        case ERakenCelestialType::BlackHole:
        {
            State.DisplayName = TEXT("New Black Hole");
            State.MassKg = 1.98847e31;
            constexpr double SpeedOfLight = 299792458.0;
            constexpr double G = 6.67430e-11;
            State.RadiusMeters =
                (2.0 * G * State.MassKg) / (SpeedOfLight * SpeedOfLight);
            State.SurfaceTemperatureKelvin = 0.00000001;
            State.BaseColor = FLinearColor::Black;
            break;
        }

        default:
            State.DisplayName = TEXT("New Body");
            State.MassKg = 1.0e20;
            State.RadiusMeters = 1.0e5;
            State.BaseColor = FLinearColor::Gray;
            break;
    }

    const FGuid Id = Simulation->AddBody(State);
    FRakenCelestialState StoredState;

    if (!Simulation->GetBody(Id, StoredState))
    {
        return;
    }

    TSubclassOf<ARakenCelestialBody> VisualClass = ARakenCelestialBody::StaticClass();

    if (Type == ERakenCelestialType::BlackHole)
    {
        VisualClass = ARakenBlackHoleBody::StaticClass();
    }

    ARakenCelestialBody* Visual = GetWorld()->SpawnActor<ARakenCelestialBody>(
        VisualClass,
        FVector::ZeroVector,
        FRotator::ZeroRotator);

    if (Visual)
    {
        Visual->BindToState(StoredState);
        SelectedBody = Visual;
    }
}

void ARakenPlayerController::QuickSave()
{
    if (URakenSimulationSubsystem* Simulation =
        GetWorld() ? GetWorld()->GetSubsystem<URakenSimulationSubsystem>() : nullptr)
    {
        Simulation->SaveSnapshot(TEXT("quick"));
    }
}

void ARakenPlayerController::QuickLoad()
{
    if (URakenSimulationSubsystem* Simulation =
        GetWorld() ? GetWorld()->GetSubsystem<URakenSimulationSubsystem>() : nullptr)
    {
        if (Simulation->LoadSnapshot(TEXT("quick")))
        {
            ClearSelection();
            RefreshBodyVisuals();
        }
    }
}

void ARakenPlayerController::RefreshBodyVisuals()
{
    UWorld* World = GetWorld();
    URakenSimulationSubsystem* Simulation =
        World ? World->GetSubsystem<URakenSimulationSubsystem>() : nullptr;

    if (!World || !Simulation)
    {
        return;
    }

    TArray<ARakenCelestialBody*> Existing;

    for (TActorIterator<ARakenCelestialBody> It(World); It; ++It)
    {
        Existing.Add(*It);
    }

    for (ARakenCelestialBody* Actor : Existing)
    {
        if (IsValid(Actor))
        {
            Actor->Destroy();
        }
    }

    for (const FRakenCelestialState& State : Simulation->GetBodies())
    {
        TSubclassOf<ARakenCelestialBody> VisualClass = ARakenCelestialBody::StaticClass();

        if (State.Type == ERakenCelestialType::BlackHole)
        {
            VisualClass = ARakenBlackHoleBody::StaticClass();
        }

        ARakenCelestialBody* Visual = World->SpawnActor<ARakenCelestialBody>(
            VisualClass,
            FVector::ZeroVector,
            FRotator::ZeroRotator);

        if (Visual)
        {
            Visual->BindToState(State);
        }
    }
}

void ARakenPlayerController::ToggleSizeComparison()
{
    if (ARakenHUD* RakenHUD = Cast<ARakenHUD>(GetHUD()))
    {
        RakenHUD->ToggleSizeComparison();
    }
}
