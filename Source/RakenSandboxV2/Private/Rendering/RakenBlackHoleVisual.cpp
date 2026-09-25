#include "Rendering/RakenBlackHoleVisual.h"

#include "Components/StaticMeshComponent.h"
#include "GameFramework/RotatingMovementComponent.h"
#include "UObject/ConstructorHelpers.h"

ARakenBlackHoleVisual::ARakenBlackHoleVisual()
{
    PrimaryActorTick.bCanEverTick = false;

    EventHorizon = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("EventHorizon"));
    RootComponent = EventHorizon;

    AccretionDisk = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("AccretionDisk"));
    AccretionDisk->SetupAttachment(EventHorizon);

    Rotation = CreateDefaultSubobject<URotatingMovementComponent>(TEXT("DiskRotation"));
    Rotation->RotationRate = FRotator(0.0, 22.0, 0.0);

    static ConstructorHelpers::FObjectFinder<UStaticMesh> SphereMesh(
        TEXT("/Engine/BasicShapes/Sphere.Sphere"));

    static ConstructorHelpers::FObjectFinder<UStaticMesh> CylinderMesh(
        TEXT("/Engine/BasicShapes/Cylinder.Cylinder"));

    if (SphereMesh.Succeeded())
    {
        EventHorizon->SetStaticMesh(SphereMesh.Object);
    }

    if (CylinderMesh.Succeeded())
    {
        AccretionDisk->SetStaticMesh(CylinderMesh.Object);
    }

    EventHorizon->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    AccretionDisk->SetCollisionEnabled(ECollisionEnabled::NoCollision);
}

void ARakenBlackHoleVisual::OnConstruction(const FTransform& Transform)
{
    Super::OnConstruction(Transform);

    const double SphereEngineRadiusCm = 50.0;
    const double HorizonScale = FMath::Max(HorizonRadiusCm / SphereEngineRadiusCm, 0.001);
    EventHorizon->SetRelativeScale3D(FVector(HorizonScale));

    const double CylinderEngineRadiusCm = 50.0;
    const double DiskXY = FMath::Max(DiskOuterRadiusCm / CylinderEngineRadiusCm, 0.001);

    AccretionDisk->SetRelativeScale3D(FVector(DiskXY, DiskXY, 0.015));
}
