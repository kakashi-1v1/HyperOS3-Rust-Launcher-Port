# Launcher helper (AGPL-3.0)

`helper/` is the source of `libkashidock.so`, the native helper inside the patched launcher of this port. It is
derived from [HyperChanger](https://github.com/ColdP/HyperChanger) (AGPL-3.0, Copyright 2026 btm_m / ColdP) and
distributed under the same license.

It is the HyperOS 4 mod's helper plus what this port needs on HyperOS 3: inside the launcher process only,
`__system_property_get` / `__system_property_read_callback` report `ro.mi.os.version.code` 4 and
`ro.mi.os.version.name` OS4.0 when the system is older (the import slots of the loaded libraries point at wrappers),
so the launcher's HyperOS 4-only features turn on.

The Dock / soft glass patch description is in the
[HyperOS 4 mod repository](https://github.com/Mods-Center/HyperOS-Rust-Launcher-Mod/tree/main/launcher-patches).

Build: `./build.sh` in Termux on an arm64 phone, or with the Android NDK:
`CC="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android35-clang" ./build.sh`.
