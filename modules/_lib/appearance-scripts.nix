# 外观相关 activation 脚本的打包。
#
# 不是 Aspect：只导出三个可执行脚本，供 desktop-appearance 接线、checks 直接调用。
# runtimeInputs 决定脚本可见的命令；正文在 modules/_lib/scripts/ 下。
pkgs:
let
  runtimeInputs = with pkgs; [
    coreutils
    diffutils
    findutils
    gawk
    gnugrep
    gnused
    jq
    util-linux
  ];

  mk = name: pkgs.writeShellApplication {
    inherit name runtimeInputs;
    text = builtins.readFile (./scripts + "/${name}.sh");
  };
in
{
  seed = mk "seed-appearance";
  dmsDefaults = mk "dms-defaults";
  gtkLegacyCleanup = mk "gtk-legacy-cleanup";
}
