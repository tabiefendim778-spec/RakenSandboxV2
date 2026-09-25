# RAKEN SANDBOX V2

Unreal Engine 5 C++ rebuild of RAKEN SANDBOX.

## Current milestone

The repository now contains a real Unreal C++ gameplay core:

- Double-precision celestial state model
- N-body gravity solver using SI units
- Velocity-Verlet integration
- Collision/merge handling
- Sun / Earth / Moon bootstrap simulation
- Runtime celestial actors
- Free-flight camera controls
- Compatibility → Cinematic quality presets
- Physics automation test
- Automatic starter-map generation
- One-click Windows build entry point
- Universe Sandbox source-build inventory tooling for the porting stage

## Quick start

1. Install Unreal Engine 5.8 and Visual Studio C++ tools.
2. Clone/download this repository.
3. Run `BUILD_V2.bat`.
4. The script generates the starter map, builds C++, runs physics tests, then attempts a Win64 Shipping package.

If Unreal is installed somewhere non-standard, set `UE_ROOT` to the Unreal Engine root directory.

## Universe Sandbox porting inventory

Run `SCAN_UNIVERSE_SANDBOX.bat` and point it at the source/build folder. It produces deterministic CSV/JSON inventories for managed code, shaders, textures, audio and data so the Unreal port can be tracked instead of copied blindly.

## Release rule

A build is not treated as ready until compile, map startup, render/camera checks, physics tests and runtime smoke checks pass.
