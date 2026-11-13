# 首启种子：只在目标不存在时写入。由 home-manager activation 调用。
#
# 不由 writeShellApplication 加 shebang；参数全部显式传入 —— 激活是 systemd 服务，
# 环境里没有 XDG_*，路径以 Nix 求值结果为唯一权威（ADR-0007）。

dry_run=
config=
state=
pictures=
templates=
wallpaper=
bookmarks=
shell_template=
cava_fallback=

die() { echo "seed-appearance: $*" >&2; exit 2; }

run() {
  if [ -n "$dry_run" ]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

while [ $# -gt 0 ]; do
  case $1 in
    --dry-run) dry_run=1; shift ;;
    --config) [ $# -ge 2 ] || die "missing value for --config"; config=$2; shift 2 ;;
    --state) [ $# -ge 2 ] || die "missing value for --state"; state=$2; shift 2 ;;
    --pictures) [ $# -ge 2 ] || die "missing value for --pictures"; pictures=$2; shift 2 ;;
    --templates) [ $# -ge 2 ] || die "missing value for --templates"; templates=$2; shift 2 ;;
    --wallpaper) [ $# -ge 2 ] || die "missing value for --wallpaper"; wallpaper=$2; shift 2 ;;
    --bookmarks) [ $# -ge 2 ] || die "missing value for --bookmarks"; bookmarks=$2; shift 2 ;;
    --shell-template) [ $# -ge 2 ] || die "missing value for --shell-template"; shell_template=$2; shift 2 ;;
    --cava-fallback) [ $# -ge 2 ] || die "missing value for --cava-fallback"; cava_fallback=$2; shift 2 ;;
    *) die "unknown argument: $1" ;;
  esac
done

for required in config state pictures templates wallpaper bookmarks shell_template cava_fallback; do
  [ -n "${!required:-}" ] || die "missing required argument: --${required//_/-}"
done

for input in "$wallpaper" "$bookmarks" "$shell_template" "$cava_fallback"; do
  [ -r "$input" ] || die "input not readable: $input"
done

wall_dir="$pictures/Wallpapers"
dms_state="$state/dms"

run install -d "$wall_dir" "$dms_state" "$pictures/Screenshots"
run install -d "$config/dgop" "$config/yazi" "$config/fastfetch" "$config/kitty" "$config/fuzzel" "$config/cava/themes"

if [ ! -e "$config/cava/themes/matugen" ]; then
  run install -m644 "$cava_fallback" "$config/cava/themes/matugen"
fi

if [ ! -e "$config/gtk-3.0/bookmarks" ]; then
  run install -Dm644 "$bookmarks" "$config/gtk-3.0/bookmarks"
fi

if [ ! -e "$templates/new.sh" ]; then
  run install -Dm755 "$shell_template" "$templates/new.sh"
fi

if [ ! -e "$wall_dir/default.png" ]; then
  run cp -f "$wallpaper" "$wall_dir/default.png"
fi

# DMS 会话状态：只写一次，后续由 DMS 自己维护。用 jq 生成
# JSON，避免路径里的引号或反斜杠把文件写坏。
if [ ! -s "$dms_state/session.json" ]; then
  if [ -n "$dry_run" ]; then
    echo "[dry-run] write $dms_state/session.json"
  else
    jq -n --arg path "$wall_dir/default.png" '{ wallpaperPath: $path }' > "$dms_state/session.json"
  fi
fi

# matugen 的输出文件在首次生成前不存在，先放空文件避免 kitty / fuzzel 的
# include 失败（kitty.conf 与 fuzzel.ini 都直接 include 这三个文件）。
for placeholder in "$config/kitty/dank-theme.conf" "$config/kitty/dank-tabs.conf" "$config/fuzzel/colors.ini"; do
  if [ ! -e "$placeholder" ]; then
    if [ -n "$dry_run" ]; then
      echo "[dry-run] touch $placeholder"
    else
      : > "$placeholder"
    fi
  fi
done
