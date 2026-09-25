#include "Player/RakenSpacePawn.h"

#include "Camera/CameraComponent.h"
#include "Components/SceneComponent.h"

ARakenSpacePawn::ARakenSpacePawn()
{
    PrimaryActorTick.bCanEverTick = true;
    AutoPossessPlayer = EAutoReceiveInput::Player0;

    SceneRoot = CreateDefaultSubobject<USceneComponent>(TEXT("SceneRoot"));
    RootComponent = SceneRoot;

    Camera = CreateDefaultSubobject<UCameraComponent>(TEXT("Camera"));
    Camera->SetupAttachment(SceneRoot);
    Camera->bUsePawnControlRotation = false;
}

void ARakenSpacePawn::Tick(const float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);

    const double Speed = MovementSpeedCmPerSecond * (bBoost ? BoostMultiplier : 1.0);

    const FVector Movement =
        GetActorForwardVector() * MoveForwardValue
        + GetActorRightVector() * MoveRightValue
        + GetActorUpVector() * MoveUpValue;

    if (!Movement.IsNearlyZero())
    {
        AddActorWorldOffset(Movement.GetClampedToMaxSize(1.0) * Speed * DeltaSeconds);
    }
}

void ARakenSpacePawn::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAxis(TEXT("MoveForward"), this, &ARakenSpacePawn::MoveForward);
    PlayerInputComponent->BindAxis(TEXT("MoveRight"), this, &ARakenSpacePawn::MoveRight);
    PlayerInputComponent->BindAxis(TEXT("MoveUp"), this, &ARakenSpacePawn::MoveUp);
    PlayerInputComponent->BindAxis(TEXT("Turn"), this, &ARakenSpacePawn::Turn);
    PlayerInputComponent->BindAxis(TEXT("LookUp"), this, &ARakenSpacePawn::LookUp);

    PlayerInputComponent->BindAction(TEXT("Boost"), IE_Pressed, this, &ARakenSpacePawn::BoostPressed);
    PlayerInputComponent->BindAction(TEXT("Boost"), IE_Released, this, &ARakenSpacePawn::BoostReleased);
}

void ARakenSpacePawn::MoveForward(const float Value)
{
    MoveForwardValue = Value;
}

void ARakenSpacePawn::MoveRight(const float Value)
{
    MoveRightValue = Value;
}

void ARakenSpacePawn::MoveUp(const float Value)
{
    MoveUpValue = Value;
}

void ARakenSpacePawn::Turn(const float Value)
{
    AddActorLocalRotation(FRotator(0.0, Value, 0.0));
}

void ARakenSpacePawn::LookUp(const float Value)
{
    FRotator Rotation = GetActorRotation();
    Rotation.Pitch = FMath::Clamp(Rotation.Pitch + Value, -89.0, 89.0);
    SetActorRotation(Rotation);
}

void ARakenSpacePawn::BoostPressed()
{
    bBoost = true;
}

void ARakenSpacePawn::BoostReleased()
{
    bBoost = false;
}
