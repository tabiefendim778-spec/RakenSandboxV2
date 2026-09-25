#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "RakenGameMode.generated.h"

class ARakenCelestialBody;

UCLASS()
class RAKENSANDBOXV2_API ARakenGameMode : public AGameModeBase
{
    GENERATED_BODY()

public:
    ARakenGameMode();

protected:
    virtual void BeginPlay() override;

private:
    UPROPERTY()
    TArray<TObjectPtr<ARakenCelestialBody>> SpawnedBodies;

    void BootstrapSolarSystem();
};
