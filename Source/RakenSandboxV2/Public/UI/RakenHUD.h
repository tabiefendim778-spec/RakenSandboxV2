#pragma once

#include "CoreMinimal.h"
#include "GameFramework/HUD.h"
#include "RakenHUD.generated.h"

UCLASS()
class RAKENSANDBOXV2_API ARakenHUD : public AHUD
{
    GENERATED_BODY()

public:
    virtual void DrawHUD() override;

    UFUNCTION(BlueprintCallable, Category="RAKEN|UI")
    void ToggleSizeComparison() { bShowSizeComparison = !bShowSizeComparison; }

private:
    bool bShowSizeComparison = false;

    void DrawTextLine(const FString& Text, float& Y, const FLinearColor& Color, float Scale = 1.0f);
    void DrawSizeComparison();
};
