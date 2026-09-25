#include "Rendering/RakenStarfield.h"

#include "Components/HierarchicalInstancedStaticMeshComponent.h"
#include "Materials/MaterialInterface.h"
#include "UObject/ConstructorHelpers.h"

ARakenStarfield::ARakenStarfield()
{
    PrimaryActorTick.bCanEverTick = false;

    Stars = CreateDefaultSubobject<UHierarchicalInstancedStaticMeshComponent>(TEXT("Stars"));
    RootComponent = Stars;
    Stars->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    Stars->SetCastShadow(false);

    static ConstructorHelpers::FObjectFinder<UStaticMesh> SphereMesh(
        TEXT("/Engine/BasicShapes/Sphere.Sphere"));

    if (SphereMesh.Succeeded())
    {
        Stars->SetStaticMesh(SphereMesh.Object);
    }
}

void ARakenStarfield::BeginPlay()
{
    Super::BeginPlay();

    if (UMaterialInterface* StarMaterial =
        LoadObject<UMaterialInterface>(
            nullptr,
            TEXT("/Game/RAKEN/Materials/M_RakenStar.M_RakenStar")))
    {
        Stars->SetMaterial(0, StarMaterial);
    }

    BuildStarfield();
}

void ARakenStarfield::BuildStarfield()
{
    Stars->ClearInstances();

    FRandomStream Random(RandomSeed);

    for (int32 Index = 0; Index < StarCount; ++Index)
    {
        FVector Direction(
            Random.FRandRange(-1.0f, 1.0f),
            Random.FRandRange(-1.0f, 1.0f),
            Random.FRandRange(-1.0f, 1.0f));

        if (!Direction.Normalize())
        {
            --Index;
            continue;
        }

        const double RadiusJitter = Random.FRandRange(0.92f, 1.08f);
        const FVector Position = Direction * RadiusCm * RadiusJitter;
        const float Size = Random.FRandRange(0.015f, 0.065f);

        FTransform Transform;
        Transform.SetLocation(Position);
        Transform.SetScale3D(FVector(Size));

        Stars->AddInstance(Transform);
    }
}
