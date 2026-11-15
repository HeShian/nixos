{
  self,
  home-manager,
  lib,
  pkgs,
  appearance,
  desktopHosts,
}:
let
  fixtureRoot = "/desktop-check-home";
  fixture = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit appearance; };
    modules = [
      ./appearance-activation.nix
      (import ./dotfiles.nix (toString ../../dotfiles))
      {
        home.username = "fixture";
        home.homeDirectory = fixtureRoot;
        home.stateVersion = "25.05";
        xdg = {
          enable = true;
          configHome = "${fixtureRoot}/config with spaces";
          dataHome = "${fixtureRoot}/data with spaces";
          cacheHome = "${fixtureRoot}/cache with spaces";
          stateHome = "${fixtureRoot}/state with spaces";
          userDirs = {
            enable = true;
            pictures = "${fixtureRoot}/my pictures";
            templates = "${fixtureRoot}/my templates";
          };
        };
      }
    ];
  };

  activation = fixture.config.home.activation;
  dag = fixture.config.lib.dag.topoSort activation;
  selectedEntries = names: lib.filter (entry: builtins.elem entry.name names) dag.result;
  appearanceEntries = selectedEntries [
    "writeBoundary"
    "dms-appearance-seed"
    "dms-theme-defaults"
    "gtk-legacy-cleanup"
  ];
  dotfileEntries = selectedEntries [
    "checkDotfileDirectoryLinks"
    "checkLinkTargets"
    "writeBoundary"
  ];
  fixtureScript = name: entries: pkgs.writeText name (
    # Keep the evaluated suffixes and quoting; make the test independent of the build directory.
    lib.replaceStrings [ fixtureRoot ] [ "." ] (lib.concatMapStringsSep "\n" (entry: entry.data) entries)
  );

  appearanceActivation =
    assert builtins.length appearanceEntries == 4;
    assert (builtins.head appearanceEntries).name == "writeBoundary";
    fixtureScript "appearance-activation.sh" (builtins.tail appearanceEntries);
  dotfilePreflight =
    assert map (entry: entry.name) dotfileEntries == [
      "checkDotfileDirectoryLinks"
      "checkLinkTargets"
      "writeBoundary"
    ];
    fixtureScript "dotfile-preflight.sh" [ (builtins.head dotfileEntries) ];

  fcitxConverter = lib.getExe (import ./fcitx5-png.nix pkgs);

  duxFragments = map (
    host:
    let
      cfg = self.nixosConfigurations.${host}.config;
      hm = cfg.home-manager.users.${builtins.head (builtins.attrNames cfg.home-manager.users)};
    in
    assert cfg.programs.dux-files.enable;
    assert cfg.xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" == "dfiles;gtk";
    assert hm.xdg.mimeApps.defaultApplications."inode/directory" == [ "dev.duxlabs.files.desktop" ];
    pkgs.writeText "dux-files-${host}.kdl" hm.xdg.configFile."niri/dux-files.kdl".text
  ) desktopHosts;
in
{
  appearance-activation-wiring = pkgs.runCommand "appearance-activation-wiring" {
    nativeBuildInputs = [ pkgs.jq ];
  } ''
    mkdir home
    cd home
    DRY_RUN= bash -eu ${appearanceActivation}
    test -z "$(find . -mindepth 1 -print -quit)"

    mkdir -p 'config with spaces/gtk-3.0'
    printf '[Settings]\ngtk-icon-theme-name=Breeze-Dark\n' > 'config with spaces/gtk-3.0/settings.ini'
    bash -eu ${appearanceActivation}
    test -f 'my pictures/Wallpapers/default.png'
    test -x 'my templates/new.sh'
    test -f 'config with spaces/gtk-3.0/bookmarks'
    test -f 'state with spaces/dms/session.json'
    test -f 'data with spaces/icons/.adwaita-matugen.lock'
    test -d 'cache with spaces/nixos-migration-backup'
    grep -Fx ${lib.escapeShellArg "gtk-icon-theme-name=${appearance.icons.fallback}"} \
      'config with spaces/gtk-3.0/settings.ini'
    jq -e --arg theme ${lib.escapeShellArg appearance.cursor.theme} \
      --argjson size ${toString appearance.cursor.size} \
      '.cursorSettings == {theme: $theme, size: $size}' \
      'config with spaces/dms/settings.json' >/dev/null
    touch "$out"
  '';

  dotfile-directory-preflight = pkgs.runCommand "dotfile-directory-preflight" { } ''
    bash -eu ${dotfilePreflight}

    config='config with spaces'
    mkdir -p "$config"/{matugen,niri/scripts}
    bash -eu ${dotfilePreflight}

    for suffix in matugen niri/scripts; do
      target="$config/$suffix"
      rmdir "$target"
      for destination in "$PWD/old-working-tree" "$PWD/old-store-snapshot"; do
        ln -s "$destination" "$target"
        if bash -eu ${dotfilePreflight} 2>message; then
          echo "Accepted old directory link: $target" >&2
          exit 1
        fi
        grep -F "$suffix" message
        test "$(readlink "$target")" = "$destination"
        test ! -e "$destination"
        unlink "$target"
      done
      mkdir "$target"
    done

    bash -eu ${dotfilePreflight}
    touch "$out"
  '';

  dux-files-niri-config = pkgs.runCommand "dux-files-niri-config" {
    nativeBuildInputs = [ pkgs.niri ];
  } ''
    cp -R ${../../dotfiles/.config/niri} cfg
    chmod u+w cfg
    ! grep -Eq 'dfiles|Dux Files' cfg/binds.kdl cfg/windowrules.kdl
    niri validate --config cfg/config.kdl

    for fragment in ${lib.concatStringsSep " " (map toString duxFragments)}; do
      grep -F 'include optional=true "dux-files.kdl"' cfg/config.kdl
      grep -F 'Mod+E ' "$fragment"
      grep -F 'Mod+Alt+E ' "$fragment"
      cp "$fragment" cfg/dux-files.kdl
      niri validate --config cfg/config.kdl
      rm cfg/dux-files.kdl
    done
    touch "$out"
  '';

  fcitx5-png-theme = pkgs.runCommand "fcitx5-png-theme" { } ''
    source="$PWD/source theme"
    theme="$PWD/published theme"
    mkdir "$source"
    ${fcitxConverter} "$source" "$theme"
    test ! -e "$theme"

    cat > "$source/theme.conf" <<'CONF'
    [Metadata]
    Name=DMS
    [InputPanel]
    BlurMask=panel.svg
    HighlightBackgroundColor=#000000
    [InputPanel/Background]
    Image=panel.svg
    [InputPanel/Highlight]
    Image=highlight.svg
    CONF
    cat > "$source/panel.svg" <<'SVG'
    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48">
      <rect width="48" height="48" fill="#111122"/>
    </svg>
    SVG
    cp "$source/panel.svg" "$source/highlight.svg"
    before=$(sha256sum "$source"/*)

    ${fcitxConverter} "$source" "$theme"
    test "$before" = "$(sha256sum "$source"/*)"
    test -s "$theme/panel.png"
    test -s "$theme/highlight.png"
    grep -Fx 'Image=panel.png' "$theme/theme.conf"
    grep -Fx 'Image=highlight.png' "$theme/theme.conf"
    grep -Fx 'BlurMask=panel.png' "$theme/theme.conf"
    published=$(readlink "$theme")

    ${fcitxConverter} "$source" "$theme"
    test "$published" = "$(readlink "$theme")"

    mv "$source/highlight.svg" "$source/highlight.pending"
    ${fcitxConverter} "$source" "$theme"
    test "$published" = "$(readlink "$theme")"

    sed 's/#111122/#223344/' "$source/highlight.pending" > "$source/highlight.svg"
    mv "$source/theme.conf" "$source/theme.complete"
    printf '[Metadata]\nName=DMS\n' > "$source/theme.conf"
    ${fcitxConverter} "$source" "$theme"
    test "$published" = "$(readlink "$theme")"

    mv "$source/theme.complete" "$source/theme.conf"
    ${fcitxConverter} "$source" "$theme"
    test "$published" != "$(readlink "$theme")"
    test ! -e "$published"
    grep -iFx 'HighlightBackgroundColor=#223344' "$theme/theme.conf"
    touch "$out"
  '';
}
