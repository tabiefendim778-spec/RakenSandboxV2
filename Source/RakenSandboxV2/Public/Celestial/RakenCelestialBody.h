#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Celestial/RakenCelestialTypes.h"
#include "RakenCelestialBody.generated.h"

class UStaticMeshComponent;

UCLASS()
class RAKENSANDBOXV2_API ARakenCelestialBody : public AActor
{
    GENERATED_BODY()

public:
    ARakenCelestialBody();

    virtual void Tick(float DeltaSeconds) override;

    void BindToState(const FRakenCelestialState& State);

    UFUNCTION(BlueprintCallable, Category="RAKEN|Celestial")
    bool GetCurrentState(FRakenCelestialState& OutState) const;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="RAKEN")
    TObjectPtr<UStaticMeshComponent> BodyMesh;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="RAKEN")
    FGuid BodyId;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Rendering")
    double MinimumVisualRadiusCm = 16.0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Rendering")
    double MaximumVisualRadiusCm = 1800.0;

private:
    void ApplyState(const FRakenCelestialState& State);
    double ComputeVisualRadiusCm(const FRakenCelestialState& State) const;
};
