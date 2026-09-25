#if WITH_DEV_AUTOMATION_TESTS

#include "Misc/AutomationTest.h"
#include "Physics/RakenPhysics.h"

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
    FRakenGravityDirectionTest,
    "RAKEN.Physics.GravityDirection",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FRakenGravityDirectionTest::RunTest(const FString& Parameters)
{
    const FVector Delta(1000.0, 0.0, 0.0);
    const FVector Acceleration =
        RakenPhysics::AccelerationFromPointMass(Delta, 1.0e20, 0.0);

    TestTrue(TEXT("Gravity must pull toward the source"), Acceleration.X > 0.0);
    TestTrue(TEXT("No Y acceleration for X-only separation"), FMath::IsNearlyZero(Acceleration.Y));
    TestTrue(TEXT("No Z acceleration for X-only separation"), FMath::IsNearlyZero(Acceleration.Z));

    return true;
}

#endif
