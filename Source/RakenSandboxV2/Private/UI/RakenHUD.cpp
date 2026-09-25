#include "UI/RakenHUD.h"

#include "Celestial/RakenCelestialBody.h"
#include "Celestial/RakenCelestialTypes.h"
#include "Player/RakenPlayerController.h"
#include "Simulation/RakenSimulationSubsystem.h"
#include "Engine/Canvas.h"

void ARakenHUD::DrawTextLine(
    const FString& Text,
    float& Y,
    const FLinearColor& Color,
    const float Scale)
{
    if (!Canvas)
    {
        return;
    }

    DrawText(Text, Color, 28.0f, Y, nullptr, Scale, false);
    Y += 24.0f * Scale;
}

void ARakenHUD::DrawHUD()
{
    Super::DrawHUD();

    float Y = 28.0f;

    DrawTextLine(TEXT("RAKEN SANDBOX V2"), Y, FLinearColor(0.2f, 0.85f, 1.0f), 1.2f);

    const URakenSimulationSubsystem* Simulation =
        GetWorld() ? GetWorld()->GetSubsystem<URakenSimulationSubsystem>() : nullptr;

    if (Simulation)
    {
        DrawTextLine(
            FString::Printf(TEXT("Bodies: %d"), Simulation->GetBodyCount()),
            Y,
            FLinearColor::White);

        DrawTextLine(
            FString::Printf(TEXT("Time scale: %.0fx"), Simulation->TimeScale),
            Y,
            FLinearColor(0.8f, 0.8f, 0.8f));
    }

    const ARakenPlayerController* PC = Cast<ARakenPlayerController>(GetOwningPlayerController());
    const ARakenCelestialBody* Selected = PC ? PC->GetSelectedBody() : nullptr;

    if (!Selected)
    {
        Y += 12.0f;
        DrawTextLine(TEXT("Left click: select body"), Y, FLinearColor(0.65f, 0.65f, 0.65f));
        return;
    }

    FRakenCelestialState State;
    if (!Selected->GetCurrentState(State))
    {
        return;
    }

    Y += 12.0f;
    DrawTextLine(TEXT("SELECTED"), Y, FLinearColor(1.0f, 0.75f, 0.25f), 1.05f);
    DrawTextLine(State.DisplayName.ToString(), Y, FLinearColor::White, 1.1f);
    DrawTextLine(FString::Printf(TEXT("Mass: %.3e kg"), State.MassKg), Y, FLinearColor(0.85f, 0.85f, 0.85f));
    DrawTextLine(FString::Printf(TEXT("Radius: %.3e m"), State.RadiusMeters), Y, FLinearColor(0.85f, 0.85f, 0.85f));
    DrawTextLine(FString::Printf(TEXT("Temp: %.0f K"), State.SurfaceTemperatureKelvin), Y, FLinearColor(0.85f, 0.85f, 0.85f));
    DrawTextLine(FString::Printf(TEXT("Speed: %.1f m/s"), State.VelocityMetersPerSecond.Size()), Y, FLinearColor(0.85f, 0.85f, 0.85f));
}
