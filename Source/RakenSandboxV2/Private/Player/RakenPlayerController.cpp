#include "Player/RakenPlayerController.h"

#include "Celestial/RakenCelestialBody.h"

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
