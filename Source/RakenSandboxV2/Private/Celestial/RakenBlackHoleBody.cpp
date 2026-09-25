#include "Celestial/RakenBlackHoleBody.h"

#include "Components/StaticMeshComponent.h"
#include "GameFramework/RotatingMovementComponent.h"
#include "Materials/MaterialInterface.h"
#include "UObject/ConstructorHelpers.h"

ARakenBlackHoleBody::ARakenBlackHoleBody()
{
    AccretionDisk = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("AccretionDisk"));
    AccretionDisk->SetupAttachment(BodyMesh);
    AccretionDisk->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    AccretionDisk->SetCastShadow(false);

    static ConstructorHelpers::FObjectFinder<UStaticMesh> CylinderMesh(
        TEXT("/Engine/BasicShapes/Cylinder.Cylinder"));

    if (CylinderMesh.Succeeded())
    {
        AccretionDisk->SetStaticMesh(CylinderMesh.Object);
    }

    DiskRotation = CreateDefaultSubobject<URotatingMovementComponent>(TEXT("DiskRotation"));
    DiskRotation->RotationRate = FRotator(0.0, 28.0, 0.0);
}

void ARakenBlackHoleBody::BeginPlay()
{
    Super::BeginPlay();

    AccretionDisk->SetRelativeScale3D(
        FVector(DiskScaleMultiplier, DiskScaleMultiplier, 0.025f));

    if (UMaterialInterface* DiskMaterial =
        LoadObject<UMaterialInterface>(
            nullptr,
            TEXT("/Game/RAKEN/Materials/M_RakenAccretion.M_RakenAccretion")))
    {
        AccretionDisk->SetMaterial(0, DiskMaterial);
    }
}
