#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
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
};
