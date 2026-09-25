import unreal

ASSET_TOOLS = unreal.AssetToolsHelpers.get_asset_tools()
MATERIAL_PATH = "/Game/RAKEN/Materials"


def ensure_dir(path):
    if not unreal.EditorAssetLibrary.does_directory_exist(path):
        unreal.EditorAssetLibrary.make_directory(path)


def create_material(name):
    asset_path = f"{MATERIAL_PATH}/{name}"
    existing = unreal.EditorAssetLibrary.load_asset(asset_path)
    if existing:
        return existing

    factory = unreal.MaterialFactoryNew()
    material = ASSET_TOOLS.create_asset(name, MATERIAL_PATH, unreal.Material, factory)
    if not material:
        raise RuntimeError(f"Could not create material {asset_path}")
    return material


def add_vector_parameter(material, name, value, x=-500, y=0):
    node = unreal.MaterialEditingLibrary.create_material_expression(
        material, unreal.MaterialExpressionVectorParameter, x, y
    )
    node.set_editor_property("parameter_name", name)
    node.set_editor_property("default_value", value)
    return node


def add_scalar_parameter(material, name, value, x=-500, y=200):
    node = unreal.MaterialEditingLibrary.create_material_expression(
        material, unreal.MaterialExpressionScalarParameter, x, y
    )
    node.set_editor_property("parameter_name", name)
    node.set_editor_property("default_value", value)
    return node


def finalize(material):
    unreal.MaterialEditingLibrary.recompile_material(material)
    unreal.EditorAssetLibrary.save_loaded_asset(material)


def build_planet():
    material = create_material("M_RakenPlanet")
    if unreal.MaterialEditingLibrary.get_num_material_expressions(material) > 0:
        return

    color = add_vector_parameter(
        material, "BaseColor", unreal.LinearColor(0.08, 0.32, 0.95, 1.0), -500, -80
    )
    rough = add_scalar_parameter(material, "Roughness", 0.58, -500, 150)
    metallic = add_scalar_parameter(material, "Metallic", 0.0, -500, 260)

    unreal.MaterialEditingLibrary.connect_material_property(
        color, "", unreal.MaterialProperty.MP_BASE_COLOR
    )
    unreal.MaterialEditingLibrary.connect_material_property(
        rough, "", unreal.MaterialProperty.MP_ROUGHNESS
    )
    unreal.MaterialEditingLibrary.connect_material_property(
        metallic, "", unreal.MaterialProperty.MP_METALLIC
    )
    finalize(material)


def build_star():
    material = create_material("M_RakenStar")
    if unreal.MaterialEditingLibrary.get_num_material_expressions(material) > 0:
        return

    color = add_vector_parameter(
        material, "BaseColor", unreal.LinearColor(1.0, 0.72, 0.25, 1.0), -600, -60
    )
    strength = add_scalar_parameter(material, "EmissiveStrength", 18.0, -600, 160)
    multiply = unreal.MaterialEditingLibrary.create_material_expression(
        material, unreal.MaterialExpressionMultiply, -250, 40
    )

    unreal.MaterialEditingLibrary.connect_material_expressions(color, "", multiply, "A")
    unreal.MaterialEditingLibrary.connect_material_expressions(strength, "", multiply, "B")
    unreal.MaterialEditingLibrary.connect_material_property(
        color, "", unreal.MaterialProperty.MP_BASE_COLOR
    )
    unreal.MaterialEditingLibrary.connect_material_property(
        multiply, "", unreal.MaterialProperty.MP_EMISSIVE_COLOR
    )
    finalize(material)


def build_black_hole():
    material = create_material("M_RakenBlackHole")
    if unreal.MaterialEditingLibrary.get_num_material_expressions(material) > 0:
        return

    color = add_vector_parameter(
        material, "BaseColor", unreal.LinearColor(0.0001, 0.0001, 0.0001, 1.0), -500, -60
    )
    rough = add_scalar_parameter(material, "Roughness", 1.0, -500, 160)
    unreal.MaterialEditingLibrary.connect_material_property(
        color, "", unreal.MaterialProperty.MP_BASE_COLOR
    )
    unreal.MaterialEditingLibrary.connect_material_property(
        rough, "", unreal.MaterialProperty.MP_ROUGHNESS
    )
    finalize(material)


def build_accretion():
    material = create_material("M_RakenAccretion")
    if unreal.MaterialEditingLibrary.get_num_material_expressions(material) > 0:
        return

    color = add_vector_parameter(
        material, "DiskColor", unreal.LinearColor(1.0, 0.16, 0.015, 1.0), -600, -60
    )
    strength = add_scalar_parameter(material, "EmissiveStrength", 25.0, -600, 160)
    multiply = unreal.MaterialEditingLibrary.create_material_expression(
        material, unreal.MaterialExpressionMultiply, -250, 40
    )
    unreal.MaterialEditingLibrary.connect_material_expressions(color, "", multiply, "A")
    unreal.MaterialEditingLibrary.connect_material_expressions(strength, "", multiply, "B")
    unreal.MaterialEditingLibrary.connect_material_property(
        color, "", unreal.MaterialProperty.MP_BASE_COLOR
    )
    unreal.MaterialEditingLibrary.connect_material_property(
        multiply, "", unreal.MaterialProperty.MP_EMISSIVE_COLOR
    )
    finalize(material)


def build_atmosphere():
    material = create_material("M_RakenAtmosphere")
    if unreal.MaterialEditingLibrary.get_num_material_expressions(material) > 0:
        return

    try:
        material.set_editor_property("blend_mode", unreal.BlendMode.BLEND_TRANSLUCENT)
    except Exception as exc:
        unreal.log_warning(f"RAKEN atmosphere blend mode warning: {exc}")

    color = add_vector_parameter(
        material, "AtmosphereColor", unreal.LinearColor(0.10, 0.42, 1.0, 1.0), -700, -120
    )
    strength = add_scalar_parameter(material, "AtmosphereStrength", 1.5, -700, 100)
    opacity = add_scalar_parameter(material, "AtmosphereOpacity", 0.18, -700, 300)

    fresnel = unreal.MaterialEditingLibrary.create_material_expression(
        material, unreal.MaterialExpressionFresnel, -700, 500
    )
    multiply_color = unreal.MaterialEditingLibrary.create_material_expression(
        material, unreal.MaterialExpressionMultiply, -350, -40
    )
    multiply_opacity = unreal.MaterialEditingLibrary.create_material_expression(
        material, unreal.MaterialExpressionMultiply, -350, 260
    )

    unreal.MaterialEditingLibrary.connect_material_expressions(color, "", multiply_color, "A")
    unreal.MaterialEditingLibrary.connect_material_expressions(strength, "", multiply_color, "B")
    unreal.MaterialEditingLibrary.connect_material_expressions(fresnel, "", multiply_opacity, "A")
    unreal.MaterialEditingLibrary.connect_material_expressions(opacity, "", multiply_opacity, "B")

    unreal.MaterialEditingLibrary.connect_material_property(
        multiply_color, "", unreal.MaterialProperty.MP_EMISSIVE_COLOR
    )
    unreal.MaterialEditingLibrary.connect_material_property(
        multiply_opacity, "", unreal.MaterialProperty.MP_OPACITY
    )
    finalize(material)


def main():
    ensure_dir("/Game/RAKEN")
    ensure_dir(MATERIAL_PATH)

    builders = [
        build_planet,
        build_star,
        build_black_hole,
        build_accretion,
        build_atmosphere,
    ]

    for builder in builders:
        try:
            builder()
        except Exception as exc:
            unreal.log_error(f"RAKEN visual asset error in {builder.__name__}: {exc}")

    unreal.log("RAKEN: procedural visual materials generated.")


main()
