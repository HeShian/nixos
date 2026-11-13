#!/usr/bin/env bash
set -euo pipefail

mapfile -t colors < "$1"
if (( ${#colors[@]} != 3 )); then
    exit 1
fi
for color in "${colors[@]}"; do
    [[ $color =~ ^#[[:xdigit:]]{6}$ ]] || exit 1
done
body=${colors[0]} shadow=${colors[1]} highlight=${colors[2]}

icons=${XDG_DATA_HOME:-$HOME/.local/share}/icons
config=${XDG_CONFIG_HOME:-$HOME/.config}
source=/run/current-system/sw/share/icons/Adwaita/scalable
icon_key=/org/gnome/desktop/interface/icon-theme
mkdir -p -- "$icons"
# 与 Home Manager 的 gtk-legacy-cleanup 共用这个锁（ADR-0007）：两边必须算同一个
# 路径，否则一个写 settings.ini、一个读旧主题，会互相覆盖。Nix 侧的 xdg.dataHome
# 由 modules/checks.nix 的锁路径检查对照这里的默认值。
exec 9>"$icons/.adwaita-matugen.lock"
flock 9

current=$(dconf read "$icon_key")
current=${current//\'/}
case "$current" in
    Adwaita-Matugen-A) next=Adwaita-Matugen-B ;;
    *) next=Adwaita-Matugen-A ;;
esac

tmp=$(mktemp -d "$icons/.adwaita-matugen.XXXXXX")
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/theme/scalable/"{places,status,mimetypes}
cat > "$tmp/theme/index.theme" <<'EOF'
[Icon Theme]
Name=Adwaita Matugen
Comment=Wallpaper colors for Adwaita folders
Inherits=Papirus-Dark,Adwaita,hicolor
Directories=scalable/places,scalable/status,scalable/mimetypes

[scalable/places]
Context=Places
Size=128
Type=Scalable
MinSize=8
MaxSize=512

[scalable/status]
Context=Status
Size=128
Type=Scalable
MinSize=8
MaxSize=512

[scalable/mimetypes]
Context=MimeTypes
Size=128
Type=Scalable
MinSize=8
MaxSize=512
EOF

# Use the same Adwaita drawings and Material color roles as Shorin.
for file in "$source"/places/{folder*,user-home,user-desktop,user-bookmarks}.svg \
    "$source"/status/folder-open.svg "$source"/mimetypes/inode-directory.svg; do
    [[ -f $file ]] || continue
    sed -e "s/#a4caee/$body/g" \
        -e "s/#438de6\|#62a0ea/$shadow/g" \
        -e "s/#afd4ff\|#c0d5ea/$highlight/g" \
        "$file" > "$tmp/theme/scalable/${file#"$source/"}"
done
test -s "$tmp/theme/scalable/places/folder.svg"

if [[ $current == Adwaita-Matugen-[AB] ]] && diff -qr "$tmp/theme" "$icons/$current" >/dev/null; then
    next=$current
else
    # Publish the inactive copy first so open GTK clients can refresh the theme by name.
    rm -rf -- "$icons/$next"
    mv -- "$tmp/theme" "$icons/$next"
fi

for gtk in gtk-3.0 gtk-4.0; do
    settings="$config/$gtk/settings.ini"
    mkdir -p -- "$config/$gtk"
    if grep -Eq '^gtk-icon-theme-name[[:space:]]*=' "$settings" 2>/dev/null; then
        sed -i -E "s/^gtk-icon-theme-name[[:space:]]*=.*/gtk-icon-theme-name=$next/" "$settings"
    elif grep -qx '\[Settings\]' "$settings" 2>/dev/null; then
        sed -i "/^\[Settings\]$/a gtk-icon-theme-name=$next" "$settings"
    else
        printf '\n[Settings]\ngtk-icon-theme-name=%s\n' "$next" >> "$settings"
    fi
done
dconf write "$icon_key" "'$next'"
