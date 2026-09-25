#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "RakenStarfield.generated.h"

class UHierarchicalInstancedStaticMeshComponent;

UCLASS()
class RAKENSANDBOXV2_API ARakenStarfield : public AActor
{
    GENERATED_BODY()

public:
    ARakenStarfield();

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Starfield")
    int32 StarCount = 1200;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Starfield")
    double RadiusCm = 15000000.0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Starfield")
    int32 RandomSeed = 778;

protected:
    virtual void BeginPlay() override;

private:
    UPROPERTY(VisibleAnywhere)
    TObjectPtr<UHierarchicalInstancedStaticMeshComponent> Stars;

    void BuildStarfield();
};
