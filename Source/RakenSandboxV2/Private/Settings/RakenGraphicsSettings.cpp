#include "Settings/RakenGraphicsSettings.h"

#include "Engine/Engine.h"
#include "GameFramework/GameUserSettings.h"

void URakenGraphicsSettings::ApplyQualityPreset(const ERakenQualityPreset Preset)
{
    if (!GEngine)
    {
        return;
    }

    UGameUserSettings* Settings = GEngine->GetGameUserSettings();
    if (!Settings)
    {
        return;
    }

    int32 Scalability = 3;
    float ResolutionScale = 100.0f;

    switch (Preset)
    {
        case ERakenQualityPreset::Compatibility:
            Scalability = 0;
            ResolutionScale = 65.0f;
            break;

        case ERakenQualityPreset::Low:
            Scalability = 1;
            ResolutionScale = 75.0f;
            break;

        case ERakenQualityPreset::Medium:
            Scalability = 2;
            ResolutionScale = 85.0f;
            break;

        case ERakenQualityPreset::High:
            Scalability = 3;
            ResolutionScale = 100.0f;
            break;

        case ERakenQualityPreset::Ultra:
        case ERakenQualityPreset::Cinematic:
            Scalability = 4;
            ResolutionScale = 100.0f;
            break;
    }

    Settings->SetOverallScalabilityLevel(Scalability);
    Settings->SetResolutionScaleValueEx(ResolutionScale);
    Settings->ApplySettings(false);
}
