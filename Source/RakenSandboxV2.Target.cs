using UnrealBuildTool;

public class RakenSandboxV2Target : TargetRules
{
    public RakenSandboxV2Target(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Game;
        DefaultBuildSettings = BuildSettingsVersion.Latest;
        IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
        ExtraModuleNames.Add("RakenSandboxV2");
    }
}
