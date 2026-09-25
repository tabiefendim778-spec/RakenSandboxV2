#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "RakenGraphicsSettings.generated.h"

UENUM(BlueprintType)
enum class ERakenQualityPreset : uint8
{
    Compatibility,
    Low,
    Medium,
    High,
    Ultra,
    Cinematic
};

UCLASS()
class RAKENSANDBOXV2_API URakenGraphicsSettings : public UBlueprintFunctionLibrary
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable, Category="RAKEN|Graphics")
    static void ApplyQualityPreset(ERakenQualityPreset Preset);
};
