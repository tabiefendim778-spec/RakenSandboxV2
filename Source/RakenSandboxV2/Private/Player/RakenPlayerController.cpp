#include "Player/RakenPlayerController.h"

#include "Celestial/RakenCelestialBody.h"
#include "Simulation/RakenSimulationSubsystem.h"

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
