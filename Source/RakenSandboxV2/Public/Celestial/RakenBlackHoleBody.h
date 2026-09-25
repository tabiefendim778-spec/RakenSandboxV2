#pragma once

#include "CoreMinimal.h"
#include "Celestial/RakenCelestialBody.h"
#include "RakenBlackHoleBody.generated.h"

class UStaticMeshComponent;
class URotatingMovementComponent;

UCLASS()
class RAKENSANDBOXV2_API ARakenBlackHoleBody : public ARakenCelestialBody
{
    GENERATED_BODY()

public:
    ARakenBlackHoleBody();

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="RAKEN|BlackHole")
    TObjectPtr<UStaticMeshComponent> AccretionDisk;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|BlackHole")
    float DiskScaleMultiplier = 6.0f;

protected:
    virtual void BeginPlay() override;

private:
    UPROPERTY()
    TObjectPtr<URotatingMovementComponent> DiskRotation;
};
