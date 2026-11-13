# 上代遗留迁移：只修可辨认的 noctalia / Breeze 痕迹，动作前先备份。
# 由 home-manager activation 调用。
#
# 与 matugen 的 folder-icons.sh 共用 $data/icons/.adwaita-matugen.lock：持锁后才读当前
# GTK 主题，避免拿旧值覆盖 matugen 刚写的新主题。
#
# 干跑只做分析并打印结论，不建目录、不加锁、不写任何文件。

dry_run=
config=
data=
cache=
icon_theme=
cursor_theme=

die() { echo "gtk-legacy-cleanup: $*" >&2; exit 2; }

while [ $# -gt 0 ]; do
  case $1 in
    --dry-run) dry_run=1; shift ;;
    --config) [ $# -ge 2 ] || die "missing value for --config"; config=$2; shift 2 ;;
    --data) [ $# -ge 2 ] || die "missing value for --data"; data=$2; shift 2 ;;
    --cache) [ $# -ge 2 ] || die "missing value for --cache"; cache=$2; shift 2 ;;
    --icon-theme) [ $# -ge 2 ] || die "missing value for --icon-theme"; icon_theme=$2; shift 2 ;;
    --cursor-theme) [ $# -ge 2 ] || die "missing value for --cursor-theme"; cursor_theme=$2; shift 2 ;;
    *) die "unknown argument: $1" ;;
  esac
done

for required in config data cache icon_theme cursor_theme; do
  [ -n "${!required:-}" ] || die "missing required argument: --${required//_/-}"
done

# 读 settings.ini 里的一个键；文件或键不存在时输出空串。
read_ini_key() {
  local line
  line=$(grep -m1 -E "^[[:space:]]*$2[[:space:]]*=" "$1" 2>/dev/null || true)
  [ -n "$line" ] || return 0
  printf '%s' "${line#*=}" | sed -E 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

# 写 settings.ini 里的一个键，保持文件已有排版。
set_ini_key() {
  local file=$1 key=$2 value=$3
  if grep -Eq "^[[:space:]]*${key}[[:space:]]*=" "$file"; then
    sed -i -E "s|^[[:space:]]*${key}[[:space:]]*=.*|${key}=${value}|" "$file"
  elif grep -Eq '^\[Settings\][[:space:]]*$' "$file"; then
    sed -i -E "/^\[Settings\][[:space:]]*$/a $key=$value" "$file"
  else
    printf '\n[Settings]\n%s=%s\n' "$key" "$value" >> "$file"
  fi
}

if [ -n "$dry_run" ]; then
  for v in 3.0 4.0; do
    settings="$config/gtk-$v/settings.ini"
    [ -f "$settings" ] || continue
    echo "[dry-run] gtk-$v: icon=$(read_ini_key "$settings" gtk-icon-theme-name) cursor=$(read_ini_key "$settings" gtk-cursor-theme-name) → 目标 $icon_theme / $cursor_theme"
  done
  exit 0
fi

install -d "$data/icons"
exec 9>"$data/icons/.adwaita-matugen.lock"
flock 9

backup=
for v in 3.0 4.0; do
  dir="$config/gtk-$v"
  install -d "$dir"
  css="$dir/gtk.css"
  settings="$dir/settings.ini"

  current_icon=
  current_cursor=
  if [ -f "$settings" ] && [ ! -L "$settings" ]; then
    current_icon=$(read_ini_key "$settings" gtk-icon-theme-name)
    current_cursor=$(read_ini_key "$settings" gtk-cursor-theme-name)
  fi

  legacy_css=false
  if [ -f "$dir/noctalia.css" ] || { [ -f "$css" ] && [ ! -L "$css" ] && grep -Eq '^[[:space:]]*@import.*noctalia\.css' "$css"; }; then
    legacy_css=true
  fi
  legacy_theme=false
  case "$current_icon" in breeze|breeze-dark|Breeze|Breeze-Dark) legacy_theme=true ;; esac
  if [ "$current_cursor" = breeze_cursors ]; then
    legacy_theme=true
  fi

  if [ "$legacy_css" = true ] || [ "$legacy_theme" = true ]; then
    if [ -z "$backup" ]; then
      install -d "$cache/nixos-migration-backup"
      backup=$(mktemp -d "$cache/nixos-migration-backup/gtk-XXXXXXXX")
    fi
    cp -a "$dir" "$backup/gtk-$v"
    if [ "$legacy_css" = true ]; then
      rm -f "$dir/noctalia.css" "$dir/noctalia-extensions.css"
    fi
  fi

  if [ ! -L "$css" ]; then
    if [ "$legacy_css" = true ] && [ -f "$css" ] && grep -Eq '^[[:space:]]*@import.*noctalia\.css' "$css"; then
      sed -i -E '/^[[:space:]]*@import.*noctalia\.css/d' "$css"
    fi
    # 用户样式统一从 Dux 生成的 dank-colors.css 取色。
    if ! grep -Eq '^[[:space:]]*@import.*dank-colors\.css' "$css" 2>/dev/null; then
      tmp=$(mktemp "$dir/.gtk.css.XXXXXX")
      {
        printf '@import url("dank-colors.css");\n'
        if [ -f "$css" ]; then cat "$css"; fi
      } > "$tmp"
      mv -f "$tmp" "$css"
    fi
  fi

  if [ ! -L "$settings" ]; then
    if [ ! -e "$settings" ]; then printf '[Settings]\n' > "$settings"; fi
    case "$current_icon" in
      ""|breeze|breeze-dark|Breeze|Breeze-Dark|default|Default)
        set_ini_key "$settings" gtk-icon-theme-name "$icon_theme" ;;
    esac
    case "$current_cursor" in
      ""|breeze_cursors|default|Default)
        set_ini_key "$settings" gtk-cursor-theme-name "$cursor_theme" ;;
    esac
  fi
done
