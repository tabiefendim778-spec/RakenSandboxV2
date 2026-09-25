#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "Celestial/RakenCelestialTypes.h"
#include "RakenSimulationSubsystem.generated.h"

UCLASS()
class RAKENSANDBOXV2_API URakenSimulationSubsystem : public UTickableWorldSubsystem
{
    GENERATED_BODY()

public:
    virtual void Tick(float DeltaTime) override;
    virtual TStatId GetStatId() const override;
    virtual bool IsTickable() const override { return !IsTemplate(); }

    UFUNCTION(BlueprintCallable, Category="RAKEN|Simulation")
    FGuid AddBody(const FRakenCelestialState& State);

    UFUNCTION(BlueprintCallable, Category="RAKEN|Simulation")
    bool RemoveBody(FGuid Id);

    UFUNCTION(BlueprintCallable, Category="RAKEN|Simulation")
    void ClearBodies();

    UFUNCTION(BlueprintCallable, Category="RAKEN|Save")
    bool SaveSnapshot(const FString& SlotName = TEXT("quick"));

    UFUNCTION(BlueprintCallable, Category="RAKEN|Save")
    bool LoadSnapshot(const FString& SlotName = TEXT("quick"));

    UFUNCTION(BlueprintCallable, Category="RAKEN|Simulation")
    bool GetBody(FGuid Id, FRakenCelestialState& OutState) const;

    UFUNCTION(BlueprintPure, Category="RAKEN|Simulation")
    int32 GetBodyCount() const { return Bodies.Num(); }

    const TArray<FRakenCelestialState>& GetBodies() const { return Bodies; }

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Simulation")
    double TimeScale = 3600.0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Simulation")
    bool bPaused = false;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Simulation")
    double FixedStepSeconds = 60.0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Simulation")
    double SofteningMeters = 1000.0;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Simulation")
    int32 MaxSubstepsPerFrame = 16;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="RAKEN|Rendering")
    double PositionCentimetersPerMeter = 1.0e-7;

private:
    UPROPERTY()
    TArray<FRakenCelestialState> Bodies;

    double AccumulatorSeconds = 0.0;

    void StepSimulation(double StepSeconds);
    void CalculateAccelerations(TArray<FVector>& OutAccelerations) const;
    void ResolveCollisions();
};
