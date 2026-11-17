# Changelog

## v1.0

First release: the HyperOS 4 Rust Launcher Mod (launcher 8.01.02.9258, HyperLauncherExt 3.9) ported to HyperOS 3.

- Needs the HyperOS 3 Rust Bridge v1.2+; the installer stops when it's missing or disabled, and on HyperOS 4.
- HyperOS 4 detection forced inside the launcher (version checks and version props), so HyperOS 4-only features
  such as blur, glass and folder resizing turn on.
- Blur behind the drawer, folders and search samples the right part of the wallpaper (HyperOS 3 blur orientation).
- Recents: tapping a card right after swiping up from an app opens it with its animation, no blink after the cards
  settle.
- Live drag into recents follows the finger in more cases (still not reliable for apps opened from recents).
- Removing the module also restores the stock launcher and removes HyperLauncherExt on the next boot.
