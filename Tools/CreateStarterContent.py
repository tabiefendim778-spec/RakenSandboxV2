import unreal

MAP_PATH = "/Game/Maps/L_Startup"

if not unreal.EditorAssetLibrary.does_directory_exist("/Game/Maps"):
    unreal.EditorAssetLibrary.make_directory("/Game/Maps")

if unreal.EditorAssetLibrary.does_asset_exist(MAP_PATH):
    unreal.log("RAKEN: starter map already exists.")
else:
    unreal.EditorLevelLibrary.new_level(MAP_PATH)

    post = unreal.EditorLevelLibrary.spawn_actor_from_class(
        unreal.PostProcessVolume,
        unreal.Vector(0.0, 0.0, 0.0),
        unreal.Rotator(0.0, 0.0, 0.0),
    )
    if post:
        post.set_editor_property("unbound", True)

    unreal.EditorLevelLibrary.save_current_level()
    unreal.log("RAKEN: L_Startup created and saved.")
