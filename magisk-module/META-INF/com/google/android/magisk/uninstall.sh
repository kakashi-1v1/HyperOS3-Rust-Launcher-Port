#!/system/bin/sh
# Module removal often runs before the package manager is up, so the clean-up is done by a one-time boot script:
# - removes the patched launcher installed as an app update (the stock HyperOS 3 launcher comes back; without the
#   Rust Bridge the patched one cannot start),
# - removes HyperLauncherExt, which the module installed as a normal app.
for f in /data/system/package_cache/*/*; do
    case "$f" in *[Hh]ome*|*kashi*) rm -f "$f" ;; esac
done
S=/data/adb/service.d/kashi_os3_launcher_cleanup.sh
mkdir -p /data/adb/service.d
cat > "$S" <<'EOS'
#!/system/bin/sh
until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 5; done
sleep 5
if [ ! -d /data/adb/modules/hyperos3_rust_launcher_port ]; then
    case "$(pm path com.miui.home 2>/dev/null | head -n1)" in
        package:/data/*) pm uninstall-system-updates com.miui.home >/dev/null 2>&1 ;;
    esac
    pm uninstall com.miui.home.kashi.ext >/dev/null 2>&1
fi
rm -f "$0"
EOS
chmod 0755 "$S"
# still try right away (works when the package manager is already running)
pm uninstall com.miui.home.kashi.ext >/dev/null 2>&1
