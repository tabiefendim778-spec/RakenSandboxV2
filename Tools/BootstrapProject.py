import os
import runpy
import unreal

project_dir = unreal.Paths.project_dir()
tools_dir = os.path.join(project_dir, "Tools")

for script_name in ("CreateVisualAssets.py", "CreateStarterContent.py"):
    script_path = os.path.join(tools_dir, script_name)
    try:
        unreal.log(f"RAKEN bootstrap: running {script_name}")
        runpy.run_path(script_path, run_name="__main__")
    except Exception as exc:
        unreal.log_error(f"RAKEN bootstrap failed in {script_name}: {exc}")
        raise

unreal.log("RAKEN bootstrap complete.")
