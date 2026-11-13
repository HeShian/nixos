# DMS 首启种子与缺键补齐。由 home-manager activation 调用。
#
# 只创建首启种子或补齐缺失的默认值；已有值（含 false / null）全部保留。
# 用户态数据坏了（settings.json 不是合法 JSON）只警告并保留原文件，不阻断激活。

dry_run=
settings=
defaults=

die() { echo "dms-defaults: $*" >&2; exit 2; }
warn() { echo "dms-defaults: $*" >&2; }

while [ $# -gt 0 ]; do
  case $1 in
    --dry-run) dry_run=1; shift ;;
    --settings) [ $# -ge 2 ] || die "missing value for --settings"; settings=$2; shift 2 ;;
    --defaults) [ $# -ge 2 ] || die "missing value for --defaults"; defaults=$2; shift 2 ;;
    *) die "unknown argument: $1" ;;
  esac
done

[ -n "$settings" ] || die "missing required argument: --settings"
[ -n "$defaults" ] || die "missing required argument: --defaults"
[ -r "$defaults" ] || die "defaults file not readable: $defaults"
jq -e 'type == "object"' "$defaults" >/dev/null 2>&1 || die "defaults file is not a JSON object: $defaults"

if [ -n "$dry_run" ]; then
  echo "[dry-run] would seed or fill defaults in $settings"
  exit 0
fi

install -d "$(dirname "$settings")"

# 符号链接由用户或 DMS 管理，不动。
if [ -L "$settings" ]; then
  exit 0
fi

if [ ! -e "$settings" ]; then
  # noclobber 避免覆盖恰好由 DMS 创建的文件。
  if (set -o noclobber; cat "$defaults" > "$settings") 2>/dev/null; then
    :
  fi
  [ -f "$settings" ] || die "could not create $settings"
  exit 0
fi

# 不是普通文件（目录等）就不碰。
if [ ! -f "$settings" ]; then
  exit 0
fi

if ! jq -e 'type == "object"' "$settings" >/dev/null 2>&1; then
  warn "保留原文件：$settings 不是合法的 JSON 对象"
  exit 0
fi

snapshot=$(mktemp "$settings.hm-original.XXXXXX")
updated=$(mktemp "$settings.hm-updated.XXXXXX")
trap 'rm -f -- "$snapshot" "$updated"' EXIT
cp -- "$settings" "$snapshot"

# 只有缺键才产出候选；`$base + .` 以右侧为准，已有值（含 false / null）全部保留。
# 同时用 cmp 确认读取期间文件没被 DMS 改过，避免用旧内容覆盖新设置。
if jq -e --slurpfile base "$defaults" '
     if type == "object" and (($base[0]) + .) != .
     then ($base[0]) + . else empty end
   ' "$snapshot" > "$updated" 2>/dev/null \
   && [ -s "$updated" ] \
   && cmp -s "$settings" "$snapshot"; then
  chmod --reference="$settings" "$updated"
  mv -f -- "$updated" "$settings"
fi
