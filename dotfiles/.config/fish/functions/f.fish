function f --description '用本地壁纸作为 Fastfetch 图标'
    if set -q KITTY_WINDOW_ID
        set -l pictures (xdg-user-dir PICTURES)
        if test -d "$pictures/Wallpapers"
            set -l wallpaper (find "$pictures/Wallpapers" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print0 | shuf -z -n 1 | string split0)
            if set -q wallpaper[1]
                command fastfetch --logo-type kitty --logo "$wallpaper[1]" --logo-preserve-aspect-ratio true $argv
                return $status
            end
        end
    end
    command fastfetch $argv
end
