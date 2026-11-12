#!/usr/bin/env bash
# Run without arguments at Niri startup to watch for completed captures.
# Screenshot bindings pass a Niri action and arm the watcher before capturing.

runtime_dir=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
trigger_file="$runtime_dir/niri-screenshot-armed"

if (( $# > 0 )); then
    touch -- "$trigger_file"
    exec niri msg action "$1" --show-pointer false
fi

sound=/run/current-system/sw/share/sounds/freedesktop/stereo/camera-shutter.oga
if [[ ! -r $sound ]]; then
    sound="$HOME/.nix-profile/share/sounds/freedesktop/stereo/camera-shutter.oga"
fi

for cmd in pw-play wl-paste flock; do
    if ! command -v "$cmd" >/dev/null; then
        notify-send "截图音效" "未找到 $cmd"
        exit 1
    fi
done
if [[ ! -r $sound ]]; then
    notify-send "截图音效" "未找到快门音效文件"
    exit 1
fi

exec 9>"$runtime_dir/niri-screenshot-sound.lock" || exit 1
flock -n 9 || exit 0
rm -f -- "$trigger_file"

# The clipboard supplies the completion event for both interactive and instant captures.
# The trigger expires after 15 seconds if the region picker is cancelled.
exec wl-paste --watch bash -c '
    trigger_file=$1
    sound=$2

    [[ -f $trigger_file ]] || exit 0
    wl-paste --list-types 2>/dev/null | grep -q "^image/" || exit 0
    file_time=$(stat -c %Y -- "$trigger_file" 2>/dev/null) || exit 0
    (( $(date +%s) - file_time < 15 )) || exit 0

    rm -f -- "$trigger_file"
    exec pw-play "$sound"
' bash "$trigger_file" "$sound"
