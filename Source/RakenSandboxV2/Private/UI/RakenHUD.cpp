#include "UI/RakenHUD.h"

#include "Celestial/RakenCelestialBody.h"
#include "Celestial/RakenCelestialTypes.h"
#include "Player/RakenPlayerController.h"
#include "Simulation/RakenSimulationSubsystem.h"
#include "Engine/Canvas.h"
#include "EngineUtils.h"

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

    if (bShowSizeComparison)
    {
        DrawSizeComparison();
        return;
    }

    float Y = 28.0f;

    if (ARakenPlayerController* TrailPC = Cast<ARakenPlayerController>(GetOwningPlayerController()))
    {
        for (TActorIterator<ARakenCelestialBody> It(GetWorld()); It; ++It)
        {
            const TArray<FVector>& Trail = It->GetTrailPoints();

            for (int32 Index = 1; Index < Trail.Num(); ++Index)
            {
                FVector2D A;
                FVector2D B;

                if (TrailPC->ProjectWorldLocationToScreen(Trail[Index - 1], A, true) &&
                    TrailPC->ProjectWorldLocationToScreen(Trail[Index], B, true))
                {
                    Canvas->K2_DrawLine(
                        A,
                        B,
                        1.0f,
                        FLinearColor(0.2f, 0.55f, 1.0f, 0.35f));
                }
            }
        }
    }

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
        DrawTextLine(TEXT("1 Planet  2 Star  3 Black Hole  4 Moon"), Y, FLinearColor(0.65f, 0.65f, 0.65f));
        DrawTextLine(TEXT("[ / ] Time  Space Pause  F5 Save  F9 Load"), Y, FLinearColor(0.65f, 0.65f, 0.65f));
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

void ARakenHUD::DrawSizeComparison()
{
    if (!Canvas || !GetWorld())
    {
        return;
    }

    const URakenSimulationSubsystem* Simulation =
        GetWorld()->GetSubsystem<URakenSimulationSubsystem>();

    if (!Simulation)
    {
        return;
    }

    TArray<FRakenCelestialState> Sorted = Simulation->GetBodies();

    Sorted.Sort([](const FRakenCelestialState& A, const FRakenCelestialState& B)
    {
        return A.RadiusMeters > B.RadiusMeters;
    });

    DrawRect(
        FLinearColor(0.015f, 0.02f, 0.035f, 0.94f),
        0.0f,
        0.0f,
        Canvas->SizeX,
        Canvas->SizeY);

    float Y = 36.0f;
    DrawTextLine(
        TEXT("RAKEN SANDBOX V2 - SIZE COMPARISON"),
        Y,
        FLinearColor(0.2f, 0.85f, 1.0f),
        1.25f);

    DrawTextLine(
        TEXT("TAB: return to simulation"),
        Y,
        FLinearColor(0.65f, 0.65f, 0.65f));

    Y += 28.0f;

    const int32 Count = FMath::Min(Sorted.Num(), 14);

    if (Count == 0)
    {
        DrawTextLine(TEXT("No bodies"), Y, FLinearColor::White);
        return;
    }

    const double LargestLogRadius =
        FMath::Max(FMath::LogX(10.0, FMath::Max(Sorted[0].RadiusMeters, 1.0)), 1.0);

    for (int32 Index = 0; Index < Count; ++Index)
    {
        const FRakenCelestialState& Body = Sorted[Index];

        const double LogRadius =
            FMath::Max(FMath::LogX(10.0, FMath::Max(Body.RadiusMeters, 1.0)), 0.1);

        const float Fraction = static_cast<float>(LogRadius / LargestLogRadius);
        const float BarWidth = FMath::Max(80.0f, (Canvas->SizeX - 380.0f) * Fraction);

        DrawText(
            FString::Printf(
                TEXT("%2d. %-18s  radius %.3e m"),
                Index + 1,
                *Body.DisplayName.ToString(),
                Body.RadiusMeters),
            FLinearColor::White,
            36.0f,
            Y);

        DrawRect(
            Body.BaseColor,
            330.0f,
            Y + 4.0f,
            BarWidth,
            12.0f);

        Y += 34.0f;
    }
}
