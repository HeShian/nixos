{
  den.aspects.desktop-localization = {
    nixos.imports = [
  # 语言环境与输入法接线
  ({
        i18n = {
          defaultLocale = "zh_CN.UTF-8";
          supportedLocales = [ "zh_CN.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];
        };

        # 参考 niri 的 environment：让 Qt / SDL 程序也接入 fcitx5
        environment.variables = {
          QT_IM_MODULE = "fcitx";
          QT_IM_MODULES = "wayland;fcitx";
          SDL_IM_MODULE = "fcitx";
        };
      })

  # Fcitx5 / Rime
  ({ pkgs, ... }: {
        i18n.inputMethod = {
          enable = true;
          type = "fcitx5";
          fcitx5 = {
            waylandFrontend = true;
            addons = [
              (pkgs.fcitx5-rime.override {
                rimeDataPkgs = [
                  pkgs.rime-data
                  pkgs.rime-ice
                ];
              })
            ];

            settings = {
              # ── fcitx5 全局快捷键 / 行为（参考 config） ──────────────
              globalOptions = {
                Hotkey = {
                  EnumerateWithTriggerKeys = "True";
                  EnumerateForwardKeys = "";
                  EnumerateBackwardKeys = "";
                  EnumerateSkipFirst = "False";
                  ModifierOnlyKeyTimeout = "250";
                };
                "Hotkey/TriggerKeys" = {
                  "0" = "Super+space";
                  "1" = "Zenkaku_Hankaku";
                  "2" = "Hangul";
                };
                "Hotkey/ActivateKeys" = {
                  "0" = "Hangul_Hanja";
                };
                "Hotkey/DeactivateKeys" = {
                  "0" = "Hangul_Romaja";
                };
                # Shift 切换中英文（Rime 内部已把 Shift 设为 noop）
                "Hotkey/AltTriggerKeys" = {
                  "0" = "Shift_L";
                  "1" = "Shift_R";
                };
                "Hotkey/EnumerateGroupForwardKeys" = {
                  "0" = "Super+space";
                };
                "Hotkey/EnumerateGroupBackwardKeys" = {
                  "0" = "Shift+Super+space";
                };
                "Hotkey/PrevPage" = {
                  "0" = "Up";
                };
                "Hotkey/NextPage" = {
                  "0" = "Down";
                };
                "Hotkey/PrevCandidate" = {
                  "0" = "Shift+Tab";
                };
                "Hotkey/NextCandidate" = {
                  "0" = "Tab";
                };
                "Hotkey/TogglePreedit" = {
                  "0" = "Control+Alt+P";
                };
                Behavior = {
                  # 参考配置启动时为英文；按 Super+space（或 Shift）切换中文。
                  # 希望登录后默认中文可改成 "True"。
                  ActiveByDefault = "False";
                  resetStateWhenFocusIn = "No";
                  ShareInputState = "No";
                  PreeditEnabledByDefault = "True";
                  ShowInputMethodInformation = "True";
                  showInputMethodInformationWhenFocusIn = "False";
                  CompactInputMethodInformation = "True";
                  ShowFirstInputMethodInformation = "True";
                  DefaultPageSize = "5";
                  OverrideXkbOption = "False";
                  CustomXkbOption = "";
                  EnabledAddons = "";
                  DisabledAddons = "";
                  PreloadInputMethod = "True";
                  AllowInputMethodForPassword = "False";
                  ShowPreeditForPassword = "False";
                  AutoSavePeriod = "0";
                };
              };

              # ── 输入法分组（参考 profile）：keyboard-us + rime ───────
              inputMethod = {
                "Groups/0" = {
                  Name = "Default";
                  "Default Layout" = "us";
                  DefaultIM = "rime";
                };
                "Groups/0/Items/0" = {
                  Name = "keyboard-us";
                  Layout = "";
                };
                "Groups/0/Items/1" = {
                  Name = "rime";
                  Layout = "";
                };
                GroupOrder = {
                  "0" = "Default";
                };
              };

              addons = {
                # 参考 classicui.conf：竖排候选、滚轮翻页、字体
                classicui.globalSection = {
                  "Vertical Candidate List" = "True";
                  WheelForPaging = "True";
                  Font = "Sans Serif 11";
                  MenuFont = "Sans Serif 10";
                  TrayFont = "Sans Serif 10";
                  TrayOutlineColor = "#000000";
                  TrayTextColor = "#ffffff";
                  PreferTextIcon = "False";
                  ShowLayoutNameInIcon = "True";
                  UseInputMethodLanguageToDisplayText = "True";
                  # Dux Shell 的 matugen 模板会生成 ~/.local/share/fcitx5/themes/dms，
                  # 并在换壁纸后通过 D-Bus 重载 classicui；这里只指定主题名。
                  Theme = "dms";
                  DarkTheme = "dms";
                  UseDarkTheme = "False";
                  UseAccentColor = "True";
                  PerScreenDPI = "False";
                  ForceWaylandDPI = "0";
                  EnableFractionalScale = "True";
                };

                # 参考 punctuation.conf：数字/字母后接半角标点
                punctuation = {
                  globalSection = {
                    HalfWidthPuncAfterLetterOrNumber = "True";
                    TypePairedPunctuationsTogether = "False";
                    Enabled = "True";
                  };
                  sections.Hotkey = {
                    "0" = "Control+period";
                  };
                };
              };
            };
          };
        };
      })
];

    homeManager.imports = [
  # 输入法用户配置与 Dux 主题联动
  ({ config, lib, pkgs, ... }:
      let
        themeDir = "${config.xdg.dataHome}/fcitx5/themes/dms";
        classicUiConfig = "${config.xdg.configHome}/fcitx5/conf/classicui.conf";
      in {
        # 微信的 Qt 输入法只从用户目录读取 classicui.conf。
        home.activation.fcitx5-classicui-link = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -e ${lib.escapeShellArg classicUiConfig} ] && [ ! -L ${lib.escapeShellArg classicUiConfig} ]; then
            run install -d ${lib.escapeShellArg (builtins.dirOf classicUiConfig)}
            run ln -s /etc/xdg/fcitx5/conf/classicui.conf ${lib.escapeShellArg classicUiConfig}
          fi
        '';

        # Dux 重新生成配色后，将候选框资源转为微信内置 Qt 能读取的 PNG。
        systemd.user.paths.fcitx5-dms-png = {
          Unit.Description = "Watch the Dux Fcitx5 theme";
          Path.PathChanged = map (file: "${themeDir}/${file}") [ "theme.conf" "panel.svg" "highlight.svg" ];
          Install.WantedBy = [ "graphical-session.target" ];
        };
        systemd.user.services.fcitx5-dms-png = {
          Unit = {
            Description = "Convert the Dux Fcitx5 theme to PNG";
            # One theme change can write all three inputs and trigger a second run
            # when the converter replaces theme.conf. Keep watching during bursts.
            StartLimitIntervalSec = 0;
          };
          Service = {
            Type = "oneshot";
            Environment = "PATH=${lib.makeBinPath [ pkgs.imagemagick pkgs.coreutils pkgs.diffutils pkgs.gawk pkgs.systemd ]}";
            ExecStartPre = "${pkgs.coreutils}/bin/sleep 0.3";
            ExecStart = ''${pkgs.bash}/bin/bash "${config.xdg.configHome}/matugen/fcitx5-png.sh" "${themeDir}"'';
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };

        # Rime 用户数据：把参考配置的 schema 列表和 rime-ice 补丁交给 HM 管理
        xdg.dataFile = {
          "fcitx5/rime/default.custom.yaml".text = ''
            patch:
              schema_list:
                - schema: rime_ice
                - schema: luna_pinyin_simp
                - schema: double_pinyin_flypy
                - schema: wubi86
                - schema: bopomofo
              "menu/page_size": 6
              # Shift 交给 fcitx5 的 AltTriggerKeys（rime ↔ keyboard-us），
              # Rime 内部不再用 Shift 切中英。
              "ascii_composer/switch_key/Shift_L": noop
              "ascii_composer/switch_key/Shift_R": noop
          '';

        };
      })

  # 英文 XDG 用户目录
  ({
      xdg.userDirs = {
        enable = true;
        createDirectories = true;
      };
    })
];
  };
}
