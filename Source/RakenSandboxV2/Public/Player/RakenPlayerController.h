#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "Celestial/RakenCelestialTypes.h"
#include "RakenPlayerController.generated.h"

class ARakenCelestialBody;

UCLASS()
class RAKENSANDBOXV2_API ARakenPlayerController : public APlayerController
{
    GENERATED_BODY()

public:
    ARakenPlayerController();

    UFUNCTION(BlueprintPure, Category="RAKEN|Selection")
    ARakenCelestialBody* GetSelectedBody() const { return SelectedBody.Get(); }

    UFUNCTION(BlueprintCallable, Category="RAKEN|Selection")
    void ClearSelection();

protected:
    virtual void SetupInputComponent() override;

private:
    UPROPERTY()
    TObjectPtr<ARakenCelestialBody> SelectedBody;

    void SelectUnderCursor();
    void TogglePause();
    void FasterTime();
    void SlowerTime();
    void SpawnPlanetPreset();
    void SpawnStarPreset();
    void SpawnBlackHolePreset();
    void SpawnMoonPreset();
    void SpawnPreset(ERakenCelestialType Type);
    void QuickSave();
    void QuickLoad();
    void RefreshBodyVisuals();
};
