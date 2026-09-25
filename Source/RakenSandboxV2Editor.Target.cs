using UnrealBuildTool;

public class RakenSandboxV2EditorTarget : TargetRules
{
    public RakenSandboxV2EditorTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Editor;
        DefaultBuildSettings = BuildSettingsVersion.Latest;
        IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
        ExtraModuleNames.Add("RakenSandboxV2");
    }
}
