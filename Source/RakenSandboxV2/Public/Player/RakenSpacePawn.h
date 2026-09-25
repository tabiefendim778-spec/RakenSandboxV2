#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Pawn.h"
#include "RakenSpacePawn.generated.h"

class UCameraComponent;
class USceneComponent;

UCLASS()
class RAKENSANDBOXV2_API ARakenSpacePawn : public APawn
{
    GENERATED_BODY()

public:
    ARakenSpacePawn();

    virtual void Tick(float DeltaSeconds) override;
    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="RAKEN")
    TObjectPtr<USceneComponent> SceneRoot;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="RAKEN")
    TObjectPtr<UCameraComponent> Camera;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Camera")
    double MovementSpeedCmPerSecond = 2500000.0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Camera")
    double BoostMultiplier = 12.0;

private:
    double MoveForwardValue = 0.0;
    double MoveRightValue = 0.0;
    double MoveUpValue = 0.0;
    bool bBoost = false;

    void MoveForward(float Value);
    void MoveRight(float Value);
    void MoveUp(float Value);
    void Turn(float Value);
    void LookUp(float Value);
    void BoostPressed();
    void BoostReleased();
};
