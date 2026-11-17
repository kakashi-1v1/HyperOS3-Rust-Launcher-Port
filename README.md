<div align="center">

# HyperOS 3 Rust Launcher Port

[![Release](https://img.shields.io/github/v/release/kakashi-1v1/HyperOS3-Rust-Launcher-Port?style=for-the-badge&label=release&color=0a84ff)](https://github.com/kakashi-1v1/HyperOS3-Rust-Launcher-Port/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/kakashi-1v1/HyperOS3-Rust-Launcher-Port/total?style=for-the-badge&color=30d158)](https://github.com/kakashi-1v1/HyperOS3-Rust-Launcher-Port/releases)
[![Requires](https://img.shields.io/badge/requires-HyperOS%203%20Rust%20Bridge-ff9f0a?style=for-the-badge)](https://github.com/kakashi-1v1/HyperOS3-Rust-Bridge/releases/latest)
[![Telegram](https://img.shields.io/badge/Telegram-channel-26A5E4?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/kashis_cringey_stuffs)

</div>

The **HyperOS 4 Rust/Flutter launcher** (`com.miui.home` 8.01.02.9258), with every feature of the
[HyperOS 4 Rust Launcher Mod](https://github.com/Mods-Center/HyperOS-Rust-Launcher-Mod), **patched to run on
HyperOS 3**. It ships with **HyperLauncherExt**, the settings app that configures the launcher live, as a Magisk /
KernelSU / APatch module.

> [!IMPORTANT]
> **This module needs the [HyperOS 3 Rust Bridge](https://github.com/kakashi-1v1/HyperOS3-Rust-Bridge) (v1.2 or
> newer).** HyperOS 3 doesn't have the HyperOS 4 Rust runtime, Flutter engine, `libmisqlite3` and `librust_maml_sdk`
> this launcher is built on; the bridge installs them. Without it the launcher can't start and you have no home
> screen, so the installer refuses to continue when the bridge is missing or disabled.

## Built with AI

The HyperOS 4 launcher has no dex code: the UI is compiled Dart (AOT machine code without class names) and the
system side is compiled Rust. Every change here is a binary patch found by hand in about 30 MB of ARM64 code. This
port was made with heavy help from AI (Claude by Anthropic) under the direction of the mod author, who tested every
build on a real HyperOS 3 device. Bugs are possible; please report them with a log (HyperLauncherExt has a
diagnostics page).

## What the port changes for HyperOS 3

On top of the HyperOS 4 mod's patches, the launcher in this module has HyperOS 3 fixes:

| Area | Fix |
|---|---|
| **HyperOS 4 features** | The launcher always sees itself on HyperOS 4 (its own version checks plus `ro.mi.os.version.code/name` inside the launcher process only), so blur, glass, folder resizing and the other HyperOS 4-only features turn on |
| **Blur sampling** | The blurred wallpaper behind the drawer, folders and search showed the wrong part of the wallpaper (black towards the top): HyperOS 3 reads the blur orientation as a display rotation, the launcher now passes the right one |
| **Recents card tap** | Tapping a card right after swiping up from an app opened it without animation, or the card blinked once the cards settled. HyperOS 3 has no pre-startup animation; the app→recents transition now finishes first, only right after a tap |
| **Live drag into recents** | The app window follows the finger on the way into recents more often (window source, a fresh window driver per swipe, direct surface updates instead of HyperOS 4 frame items). See known issues |

All other settings (Dock, soft glass, search app, icons, widgets, recents options) work as described in the
[HyperOS 4 mod's README](https://github.com/Mods-Center/HyperOS-Rust-Launcher-Mod#features).

## Requirements

- **HyperOS 3** (Android 15 or newer), arm64. On HyperOS 4 the installer stops: use the
  [HyperOS 4 Rust Launcher Mod](https://github.com/Mods-Center/HyperOS-Rust-Launcher-Mod/releases/latest) there.
  If the version props don't say HyperOS 3 (some ports), it asks first (Vol+ install / Vol- cancel).
- **[HyperOS 3 Rust Bridge](https://github.com/kakashi-1v1/HyperOS3-Rust-Bridge/releases/latest) v1.2+**, installed
  and enabled.
- Magisk, KernelSU or APatch.
- **Signature verification disabled** (core patch) on stock ROMs. The patched launcher can't carry Xiaomi's
  signature.
- **KernelSU with a mount metamodule (Hybrid Mount, …):** use Rust Bridge v1.2 or newer. Older versions could end up
  in KernelSU's umount list, which hides the runtime from the launcher (`dlopen ... libmisqlite3.so not found`, no
  home screen).

## Install

1. Flash the **HyperOS 3 Rust Bridge** zip ([releases](https://github.com/kakashi-1v1/HyperOS3-Rust-Bridge/releases/latest)).
2. Flash `HyperOS3_RustLauncherPort_vX.Y.zip` from the [releases](../../releases) (no reboot needed in between).
3. Reboot. The first start after a reboot or an update can take about 10 to 15 seconds.
4. Open **HyperLauncherExt**, change settings, and tap the restart button at the top when it lights up.

The module removes the HyperOS 4 Rust Launcher Mod (`hyperos_rust_launcher_mod`) and the older dex-launcher mod
(`miui_launcher_mod`) if they're installed, because they all replace the same launcher.

**Uninstall:** remove the module and reboot. On the next boot the module's clean-up removes HyperLauncherExt and the
launcher update, so the stock HyperOS 3 launcher comes back. Remove the Rust Bridge only after that.

## Known issues

- **Live drag into recents is not reliable.** When you swipe up from an app opened from a recents card, the app
  window often stays put until you lift your finger (then it animates normally). From apps opened from the home
  screen it follows the finger. The launcher reuses the app page from the open-from-recents animation, and on
  HyperOS 3 that page doesn't move the window.
- **Quick switching** (swiping along the bottom between apps) can flicker on the right side of the card.
- **Home gesture line missing:** if the launcher crashed or restarted while the system kept running, HyperOS 3's
  SystemUI can lose the gesture line on the home screen (`already exist home bottom decoration` in the log). Restart
  SystemUI or reboot to get it back. This is a HyperOS 3 SystemUI bug, not the launcher.
- HyperOS 4 effects that need HyperOS 4's SurfaceFlinger or a newer runtime stay off or look flat. See the bridge's
  [status page](https://github.com/kakashi-1v1/HyperOS3-Rust-Bridge/blob/main/docs/status.md).

## Repository layout

| Path | What |
|---|---|
| `magisk-module/` | Module scripts (Dynamic Installer by @BlassGO) with the HyperOS 3 + Rust Bridge checks and permission allowlists; the APKs go into `files/` |
| `launcher-patches/helper/` | Source of `libkashidock.so`, the native helper inside the launcher (AGPL, HyperChanger-derived), including the HyperOS 4 version redirect used by this port |

The settings app source and the Dock / soft glass patch description are in the
[HyperOS 4 mod repository](https://github.com/Mods-Center/HyperOS-Rust-Launcher-Mod) (`HyperLauncherExt/`,
`launcher-patches/`). The runtime side is in the [Rust Bridge repository](https://github.com/kakashi-1v1/HyperOS3-Rust-Bridge).

## Credits

- **🅺🅰🆂🅷🅸** ([@kakashi1v1](https://t.me/kakashi1v1)): mod author
- **[HyperChanger](https://github.com/ColdP/HyperChanger)** by ColdP (btm_m): reference and code implementation help
  for the native Dock, Dock materials, soft glass and launcher hooks (AGPL-3.0)
- **Dynamic Installer** by @BlassGO: module installer framework
- **Claude** (Anthropic): reverse engineering, launcher and HyperOS 3 patches, native helper and most of
  HyperLauncherExt (see "Built with AI")

See [NOTICE.md](NOTICE.md) for licensing and third-party notices.

## Disclaimer

Not affiliated with or endorsed by Xiaomi. HyperOS, MIUI and the launcher are Xiaomi's property. You use this mod at
your own risk; keep a backup and a way to remove modules from recovery or safe mode.

---

<div align="center">

Made by **[🅺🅰🆂🅷🅸](https://t.me/kakashi1v1)**

[Channel](https://t.me/kashis_cringey_stuffs) · [Support group](https://t.me/bootloop_discussion) · [Report a bug](https://github.com/kakashi-1v1/HyperOS3-Rust-Launcher-Port/issues)

</div>
