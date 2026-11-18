## v1.0 (1)

**HyperOS 3 Rust Launcher Port v1.0**: the HyperOS 4 Rust Launcher Mod (launcher 8.01.02.9258, HyperLauncherExt 3.9) patched for HyperOS 3.

> [!IMPORTANT]
> Flash the **[HyperOS 3 Rust Bridge](https://github.com/kakashi-1v1/HyperOS3-Rust-Bridge/releases/latest) v1.2+ first**. Without it the launcher can't start; the installer stops when the bridge is missing or disabled. Signature verification must be disabled on stock ROMs.

### Install
1. Flash the HyperOS 3 Rust Bridge.
2. Flash `HyperOS3_RustLauncherPort_v1.0.zip`.
3. Reboot, then open HyperLauncherExt.

### HyperOS 3 fixes
- HyperOS 4 detection forced inside the launcher, so blur, glass, folder resizing and other HyperOS 4-only features turn on
- Blur behind drawer, folders and search samples the right part of the wallpaper
- Recents: tapping a card right after swiping up from an app opens it with its animation, no blink
- Live drag into recents follows the finger in more cases
- Removing the module restores the stock launcher and removes HyperLauncherExt on the next boot

### Known issues
- Live drag into recents is not reliable for apps opened from a recents card
- Quick switching can flicker on the right side of the card
- After a launcher crash, HyperOS 3 SystemUI can lose the home gesture line until SystemUI restarts or a reboot

Not for HyperOS 4: use the [HyperOS 4 Rust Launcher Mod](https://github.com/Mods-Center/HyperOS-Rust-Launcher-Mod/releases/latest) there.

