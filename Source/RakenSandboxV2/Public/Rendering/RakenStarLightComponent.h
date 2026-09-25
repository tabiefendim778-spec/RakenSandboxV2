#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "RakenStarLightComponent.generated.h"

class UPointLightComponent;

UCLASS(ClassGroup=(RAKEN), meta=(BlueprintSpawnableComponent))
class RAKENSANDBOXV2_API URakenStarLightComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    URakenStarLightComponent();

    virtual void BeginPlay() override;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Star")
    float Intensity = 150000.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Star")
    float AttenuationRadiusCm = 100000000.0f;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Star")
    FLinearColor LightColor = FLinearColor(1.0f, 0.82f, 0.62f);

private:
    UPROPERTY()
    TObjectPtr<UPointLightComponent> Light;
};
