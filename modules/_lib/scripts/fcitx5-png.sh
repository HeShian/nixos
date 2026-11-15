#!/usr/bin/env bash
set -euo pipefail

source_dir=$1
theme=$2
inputs=(theme.conf panel.svg highlight.svg)
for file in "${inputs[@]}"; do
    [[ -s $source_dir/$file ]] || exit 0
done

generations=$theme-generations
mkdir -p -- "$generations"
exec 9>"$generations/.lock"
flock 9

previous=
if [[ -L $theme ]]; then
    previous=$(readlink -- "$theme")
    case "${previous%/*}" in
        "$generations") [[ ${previous##*/} == render.* ]] || exit 1 ;;
        *) printf 'fcitx5-png: leaving unmanaged theme %s alone\n' "$theme" >&2; exit 1 ;;
    esac
elif [[ -e $theme ]]; then
    printf 'fcitx5-png: leaving unmanaged theme %s alone\n' "$theme" >&2
    exit 1
fi

work=$(mktemp -d "$generations/render.XXXXXX")
trap 'if [[ $(readlink -- "$theme" || :) != "$work" ]]; then rm -rf -- "$work"; fi' EXIT
mkdir -- "$work/source"

same_inputs() {
    local file
    for file in "${inputs[@]}"; do
        cmp -s -- "$source_dir/$file" "$work/source/$file" || return 1
    done
}

# Dux writes the files individually. Retry a snapshot invalidated during conversion.
ready=false
for attempt in 1 2 3; do
    for file in "${inputs[@]}"; do
        if [[ ! -s $source_dir/$file ]] || ! cp -- "$source_dir/$file" "$work/source/"; then
            sleep 0.3
            continue 2
        fi
    done

    for image in panel highlight; do
        if ! magick -background none "$work/source/$image.svg" -strip "PNG32:$work/$image.png"; then
            if same_inputs; then exit 1; fi
            sleep 0.3
            continue 2
        fi
    done

    # Keep solid fallbacks in sync with the centre of each nine-slice image.
    panel_color=$(magick "$work/panel.png" -format '%[hex:p{24,24}]' info:)
    highlight_color=$(magick "$work/highlight.png" -format '%[hex:p{24,24}]' info:)
    if ! awk -v panel="#${panel_color:0:6}" -v highlight="#${highlight_color:0:6}" '
        /^\[/ { section = $0 }
        section == "[Metadata]" && /^Name=/ { print "Name=DMS PNG"; next }
        section == "[InputPanel]" && /^BlurMask=panel\.svg$/ { print "BlurMask=panel.png"; next }
        section == "[InputPanel]" && /^HighlightBackgroundColor=/ {
            print "HighlightBackgroundColor=" highlight
            next
        }
        section == "[InputPanel/Background]" || section == "[InputPanel/Highlight]" {
            if (/^Color=/) next
            if (/^Image=(panel|highlight)\.(svg|png)$/) {
                sub(/\.svg$/, ".png")
                print
                if ($0 == "Image=panel.png" && section == "[InputPanel/Background]") {
                    background = 1
                    print "Color=" panel
                }
                if ($0 == "Image=highlight.png" && section == "[InputPanel/Highlight]") {
                    candidateHighlight = 1
                    print "Color=" highlight
                }
                next
            }
        }
        { print }
        END { if (!background || !candidateHighlight) exit 1 }
    ' "$work/source/theme.conf" > "$work/theme.conf"; then
        sleep 0.3
        continue
    fi

    if same_inputs; then
        ready=true
        break
    fi
    if [[ $attempt != 3 ]]; then sleep 0.3; fi
done
$ready || exit 0

if [[ -n $previous ]] && cmp -s -- "$work/theme.conf" "$theme/theme.conf" \
    && cmp -s -- "$work/panel.png" "$theme/panel.png" \
    && cmp -s -- "$work/highlight.png" "$theme/highlight.png"; then
    exit 0
fi

# Publish all files together. The watcher only observes the source directory.
rm -r -- "$work/source"
ln -s -- "$work" "$work/link"
mv -Tf -- "$work/link" "$theme"
if [[ -n $previous ]]; then rm -rf -- "$previous"; fi

if busctl --user status org.fcitx.Fcitx5 >/dev/null 2>&1; then
    busctl --user --auto-start=no call org.fcitx.Fcitx5 /controller \
        org.fcitx.Fcitx.Controller1 ReloadAddonConfig s classicui
fi
