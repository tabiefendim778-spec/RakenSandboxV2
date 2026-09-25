#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Celestial/RakenCelestialTypes.h"
#include "RakenCelestialBody.generated.h"

class UStaticMeshComponent;
class UPointLightComponent;
class UMaterialInstanceDynamic;

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

    const TArray<FVector>& GetTrailPoints() const { return TrailPoints; }

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Orbit")
    int32 MaxTrailPoints = 256;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Orbit")
    double MinTrailDistanceCm = 250.0;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="RAKEN")
    TObjectPtr<UStaticMeshComponent> BodyMesh;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="RAKEN")
    TObjectPtr<UPointLightComponent> StarLight;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category="RAKEN")
    FGuid BodyId;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Rendering")
    double MinimumVisualRadiusCm = 16.0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Rendering")
    double MaximumVisualRadiusCm = 1800.0;

private:
    UPROPERTY(Transient)
    TObjectPtr<UMaterialInstanceDynamic> DynamicMaterial;

    TArray<FVector> TrailPoints;

    void ApplyState(const FRakenCelestialState& State);
    double ComputeVisualRadiusCm(const FRakenCelestialState& State) const;
};
