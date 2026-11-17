ui_print "
             __  ___        __
            /  |/  /__  ___/ /__
           / /|_/ / _ \/ _  (_-<
          /_/  /_/\___/\_,_/___/
            _____         __
           / ___/__ ___  / /____ ____
          / /__/ -_) _ \/ __/ -_) __/
          \___/\__/_//_/\__/\__/_/
"
ui_print "      HyperOS 3 Rust Launcher Port by 🅺🅰🆂🅷🅸"
ui_print " "

LAUNCHER_PKG="com.miui.home"
OLD_MODULE_IDS="miui_launcher_mod hyperos_rust_launcher_mod"   # dex-launcher mod + HyperOS 4 mod: same APK
BRIDGE_ID="hyperos3_rust_bridge"
BRIDGE_URL="https://github.com/kakashi-1v1/HyperOS3-Rust-Bridge/releases/latest"
OS4_MOD_URL="https://github.com/Mods-Center/HyperOS-Rust-Launcher-Mod/releases/latest"

# ------------------------------------------------------------------ HyperOS 3 + Rust Bridge
# This is the HyperOS 4 launcher patched for HyperOS 3. It needs the HyperOS 3 Rust Bridge module, which installs the
# HyperOS 4 Rust runtime, Flutter engine, libmisqlite3 and librust_maml_sdk the launcher links against.
props_say_os4() {
    for p in ro.mi.os.version.name ro.mi.os.version.incremental ro.build.version.incremental ro.system.build.version.incremental; do
        case "$(getprop $p)" in OS4*|OS\ 4*|V4.*) return 0 ;; esac
    done
    code=$(getprop ro.mi.os.version.code)
    case "$code" in ''|*[!0-9]*) ;; *) [ "$code" -ge 4 ] && return 0 ;; esac
    return 1
}

props_say_os3() {
    case "$(getprop ro.mi.os.version.name)" in OS3*|OS\ 3*) return 0 ;; esac
    [ "$(getprop ro.mi.os.version.code)" = "3" ]
}

# 0 = installed and enabled (or installed in this boot, waiting for the reboot), 1 = disabled/removed, 2 = missing
bridge_state() {
    for d in "/data/adb/modules_update/$BRIDGE_ID" "/data/adb/modules/$BRIDGE_ID"; do
        [ -f "$d/module.prop" ] || continue
        if [ -e "$d/disable" ] || [ -e "$d/remove" ]; then return 1; fi
        return 0
    done
    return 2
}

bridge_code() {
    for d in "/data/adb/modules_update/$BRIDGE_ID" "/data/adb/modules/$BRIDGE_ID"; do
        [ -f "$d/module.prop" ] && { grep -m1 '^versionCode=' "$d/module.prop" | cut -d= -f2 | tr -cd 0-9; return; }
    done
    echo 0
}

bridge_version() {
    for d in "/data/adb/modules_update/$BRIDGE_ID" "/data/adb/modules/$BRIDGE_ID"; do
        [ -f "$d/module.prop" ] && { grep -m1 '^version=' "$d/module.prop" | cut -d= -f2; return; }
    done
}

# 0 = Vol+, 1 = Vol-, 2 = no key within $1 seconds
volume_key() {
    timeout_s=${1:-15}
    start=$(date +%s)
    while :; do
        ev=$(timeout 1 getevent -lqc 1 2>/dev/null)
        case "$ev" in
            *KEY_VOLUMEUP*DOWN*) return 0 ;;
            *KEY_VOLUMEDOWN*DOWN*) return 1 ;;
        esac
        [ $(( $(date +%s) - start )) -ge "$timeout_s" ] && return 2
    done
}

check_hyperos3() {
    sdk=$(getprop ro.build.version.sdk)
    case "$sdk" in ''|*[!0-9]*) sdk=0 ;; esac
    if [ "$sdk" -lt 35 ]; then
        abort "! Android $(getprop ro.build.version.release) (SDK $sdk) is too old: HyperOS 3 is Android 15 or newer."
    fi
    if props_say_os4; then
        ui_print " "
        ui_print "! This is HyperOS 4 ($(getprop ro.mi.os.version.name)). This port is for HyperOS 3 only."
        ui_print "  Use the HyperOS 4 Rust Launcher Mod instead:"
        ui_print "  $OS4_MOD_URL"
        abort "! Cancelled: HyperOS 4 detected"
    fi
    if props_say_os3; then
        ui_print "- HyperOS 3 detected ($(getprop ro.mi.os.version.name))"
    else
        ui_print " "
        ui_print "! Could not confirm HyperOS 3 (props: $(getprop ro.mi.os.version.name) / code $(getprop ro.mi.os.version.code))"
        ui_print "  Vol+ = install anyway      Vol- = cancel      (cancels in 20 s)"
        volume_key 20
        case $? in
            0) ui_print "- Installing anyway (your choice)" ;;
            *) abort "! Cancelled: HyperOS 3 not confirmed" ;;
        esac
    fi
    bridge_state
    case $? in
        0) ui_print "- HyperOS 3 Rust Bridge found ($(bridge_version))"
           if [ "$(bridge_code)" -lt 3 ] 2>/dev/null; then
               ui_print "  ! This bridge is older than v1.2. Please update it ($BRIDGE_URL):"
               ui_print "    with KernelSU + a mount metamodule older versions can hide the runtime from the launcher"
           fi ;;
        1) ui_print " "
           ui_print "! The HyperOS 3 Rust Bridge module is disabled or set to be removed."
           ui_print "  Enable it in your root manager, then flash this module again."
           abort "! Cancelled: Rust Bridge not active" ;;
        *) ui_print " "
           ui_print "! Required: HyperOS 3 Rust Bridge module (not installed)."
           ui_print "  Without it the launcher cannot start and you are left without a home screen."
           ui_print "  1. Flash the Rust Bridge: $BRIDGE_URL"
           ui_print "  2. Then flash this module (no reboot needed in between)."
           abort "! Cancelled: Rust Bridge missing" ;;
    esac
}

# ------------------------------------------------------------------ install
remove_old_module() {
    for id in $OLD_MODULE_IDS; do
        if [ -d "/data/adb/modules/$id" ] || [ -d "/data/adb/modules_update/$id" ]; then
            ui_print "- Other launcher mod ($id) found: it is removed on reboot (both replace the same launcher)"
            touch "/data/adb/modules/$id/remove" 2>/dev/null
        fi
    done
}

# Path inside $MODPATH for a file of the system image (/product and /system_ext are mounted through /system).
module_path() {
    case "$1" in
        /system/*) echo "$MODPATH$1" ;;
        *) echo "$MODPATH/system$1" ;;
    esac
}

# pm reads the APK from stdin: system_server may not be allowed to open files under /data/adb (SELinux)
kashi_pm_install() {   # <apk> -> prints pm output, returns 0 on Success
    _sz=$(stat -c %s "$1" 2>/dev/null)
    [ -n "$_sz" ] || return 1
    _o=$(cat "$1" | pm install -r -S "$_sz" 2>&1)
    echo "$_o"
    echo "$_o" | grep -q '^Success'
}

install_launcher() {
    ui_print "- Locating the system launcher..."
    pm uninstall-system-updates "$LAUNCHER_PKG" >/dev/null 2>&1
    app_path=$(pm path "$LAUNCHER_PKG" 2>/dev/null | head -n1 | sed 's/^package://')
    case "$app_path" in
        /data/*|"")
            ui_print "- System copy not reported, using the stock location"
            app_path="/product/priv-app/MiuiHome/MiuiHome.apk" ;;
    esac
    ui_print "  $app_path"
    target=$(module_path "$app_path")
    rm -rf "$MODPATH/system/product/priv-app/MiuiHome"
    mkdir -p "$(dirname "$target")"
    ui_print "- Copying the patched launcher..."
    cp -f "$MODPATH/files/MiuiHome.apk" "$target"
    is_valid "$target" || abort "! Copying the launcher failed"
    # Also try a direct update (works when signature verification is disabled); stay silent when it fails,
    # the module copy is applied on reboot either way.
    if kashi_pm_install "$MODPATH/files/MiuiHome.apk" >/dev/null 2>&1; then
        ui_print "- Launcher also updated directly"
    fi
}

# HyperLauncherExt is installed as a normal app (pm install), not as a mounted system app: mounting fails on some
# root setups (no app at all, or an icon-less leftover). With root it does everything; the module's boot script
# reinstalls it if it goes missing.
install_ext() {
    ext_pkg="com.miui.home.kashi.ext"
    apk="$MODPATH/files/HyperLauncherExt.apk"
    is_valid "$apk" || abort "! HyperLauncherExt.apk missing in the zip"
    ui_print "- Installing HyperLauncherExt (settings app)..."
    out=$(kashi_pm_install "$apk")
    if ! echo "$out" | grep -q '^Success'; then
        case "$out" in
            *UPDATE_INCOMPATIBLE*|*SIGNATURE*|*VERSION_DOWNGRADE*|*DUPLICATE*|*INCONSISTENT*)
                ui_print "  replacing the installed copy (other signature or newer version)"
                pm uninstall-system-updates "$ext_pkg" >/dev/null 2>&1
                pm uninstall "$ext_pkg" >/dev/null 2>&1
                out=$(kashi_pm_install "$apk") ;;
        esac
    fi
    if echo "$out" | grep -q '^Success'; then
        ui_print "  installed"
    else
        ui_print "  ! direct install failed: $(echo "$out" | tail -n1)"
        ui_print "  ! it is retried after the reboot, or install files/HyperLauncherExt.apk from the zip by hand"
    fi
    cp -f "$apk" "$MODPATH/kashi_ext.apk"
    # boot script (reinstall when missing or older) + uninstall script (removes the ext with the module)
    for f in service.sh uninstall.sh kashi_mount_check.sh; do
        unzip -qjo "$ZIPFILE" "META-INF/com/google/android/magisk/$f" -d "$MODPATH" >/dev/null 2>&1
    done
    ver=$(dumpsys package "$ext_pkg" 2>/dev/null | grep -m1 'versionCode=' | sed 's/.*versionCode=\([0-9]*\).*/\1/')
    [ -n "$ver" ] && echo "$ver" > "$MODPATH/kashi_ext.ver"
    chmod 0755 "$MODPATH/service.sh"
    chmod 0755 "$MODPATH/uninstall.sh"
}

clean_environment() {
    ui_print "- Cleaning launcher package cache..."
    for f in /data/system/package_cache/*/*; do
        case "$f" in *[Hh]ome*|*kashi*) rm -f "$f" ;; esac
    done
    ui_print "- Fixing contexts..."
    set_context /system "$MODPATH/system"
    rm -rf "$MODPATH/files"
    rm -f "$MODPATH/customize.sh"
}

package_extract_dir files "$MODPATH/files"
package_extract_dir system "$MODPATH/system"

check_hyperos3
ui_print "
    ------------------------------------------
                       READ!
      Signature verification must be disabled
      on stock ROMs, otherwise
      the launcher will not load.
    ------------------------------------------
"
remove_old_module
install_launcher
install_ext
clean_environment
ui_print " "
ui_print "- Done. Reboot, then open the HyperLauncherExt app to configure the launcher (grant root when asked)."

# --- Mods Center: KernelSU/APatch mount metamodule check ---
[ -f "$MODPATH/kashi_mount_check.sh" ] || unzip -qjo "$ZIPFILE" "META-INF/com/google/android/magisk/kashi_mount_check.sh" -d "$MODPATH" >/dev/null 2>&1
[ -f "$MODPATH/service.sh" ] || unzip -qjo "$ZIPFILE" "META-INF/com/google/android/magisk/service.sh" -d "$MODPATH" >/dev/null 2>&1
chmod 0755 "$MODPATH/service.sh" 2>/dev/null
[ -f "$MODPATH/kashi_mount_check.sh" ] && . "$MODPATH/kashi_mount_check.sh" && kashi_install_check
