#!/usr/bin/env bash
set -euo pipefail

theme_dir=${1:-${XDG_DATA_HOME:-$HOME/.local/share}/fcitx5/themes/dms}
[[ -d $theme_dir ]] || exit 0
cd "$theme_dir"
for file in theme.conf panel.svg highlight.svg; do
    [[ -s $file ]] || exit 0
done

tmp=$(mktemp -d .png-theme.XXXXXX)
trap 'rm -rf -- "$tmp"' EXIT
cp -- theme.conf panel.svg highlight.svg "$tmp/"

for image in panel highlight; do
    magick -background none "$tmp/$image.svg" -strip "PNG32:$tmp/$image.png"
done

# Keep solid fallbacks in sync with the centre of each nine-slice image.
panel_color=$(magick "$tmp/panel.png" -format '%[hex:p{24,24}]' info:)
highlight_color=$(magick "$tmp/highlight.png" -format '%[hex:p{24,24}]' info:)
awk -v panel="#${panel_color:0:6}" -v highlight="#${highlight_color:0:6}" '
    /^\[/ { section = $0 }
    section == "[InputPanel]" && /^HighlightBackgroundColor=/ {
        print "HighlightBackgroundColor=" highlight
        next
    }
    section == "[InputPanel/Background]" || section == "[InputPanel/Highlight]" {
        if (/^Color=/) next
        if (/^Image=(panel|highlight)\.(svg|png)$/) {
            sub(/\.svg$/, ".png")
            print
            print "Color=" (section == "[InputPanel/Background]" ? panel : highlight)
            next
        }
    }
    { print }
' "$tmp/theme.conf" > "$tmp/theme-png.conf"

# If Dux regenerated the inputs during conversion, let the next path event retry.
for file in theme.conf panel.svg highlight.svg; do
    cmp -s -- "$file" "$tmp/$file" || exit 0
done

changed=false
for image in panel.png highlight.png; do
    if ! cmp -s -- "$tmp/$image" "$image"; then
        mv -f -- "$tmp/$image" "$image"
        changed=true
    fi
done
if ! cmp -s -- "$tmp/theme-png.conf" theme.conf; then
    mv -f -- "$tmp/theme-png.conf" theme.conf
    changed=true
fi
if $changed && busctl --user status org.fcitx.Fcitx5 >/dev/null 2>&1; then
    busctl --user --auto-start=no call org.fcitx.Fcitx5 /controller \
        org.fcitx.Fcitx.Controller1 ReloadAddonConfig s classicui
fi
