#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "RakenBlackHoleVisual.generated.h"

class UStaticMeshComponent;
class URotatingMovementComponent;

UCLASS()
class RAKENSANDBOXV2_API ARakenBlackHoleVisual : public AActor
{
    GENERATED_BODY()

public:
    ARakenBlackHoleVisual();

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="RAKEN|BlackHole")
    TObjectPtr<UStaticMeshComponent> EventHorizon;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="RAKEN|BlackHole")
    TObjectPtr<UStaticMeshComponent> AccretionDisk;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|BlackHole")
    double HorizonRadiusCm = 200.0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|BlackHole")
    double DiskOuterRadiusCm = 1200.0;

protected:
    virtual void OnConstruction(const FTransform& Transform) override;

private:
    UPROPERTY()
    TObjectPtr<URotatingMovementComponent> Rotation;
};
