#include "Rendering/RakenStarLightComponent.h"

#include "Components/PointLightComponent.h"
#include "GameFramework/Actor.h"

URakenStarLightComponent::URakenStarLightComponent()
{
    PrimaryComponentTick.bCanEverTick = false;
}

void URakenStarLightComponent::BeginPlay()
{
    Super::BeginPlay();

    AActor* Owner = GetOwner();
    if (!Owner)
    {
        return;
    }

    Light = NewObject<UPointLightComponent>(Owner, TEXT("RakenStarLight"));
    if (!Light)
    {
        return;
    }

    Light->SetupAttachment(Owner->GetRootComponent());
    Light->SetIntensity(Intensity);
    Light->SetAttenuationRadius(AttenuationRadiusCm);
    Light->SetLightColor(LightColor);
    Light->SetCastShadows(true);
    Light->RegisterComponent();
}
