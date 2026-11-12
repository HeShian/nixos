{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  fetchurl,
  nodejs_24,
  electron_44-bin,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  wrapGAppsHook3,
  gsettings-desktop-schemas,
  glib,
  gtk3,
  gtk4,
  xdg-utils,
}:
let
  version = "0.13.2";

  # Harness's native loader checks Electron's exact Node/V8 fingerprint.
  electron = electron_44-bin.overrideAttrs {
    version = "44.7.0";
    src = fetchurl {
      url = "https://github.com/electron/electron/releases/download/v44.7.0/electron-v44.7.0-linux-x64.zip";
      sha256 = "3ae7d5bdad61c664486c6ab61361dd084d064c8c08af8d13a687096e18ce555a";
    };
  };
in
buildNpmPackage {
  pname = "dsh-desktop";
  inherit version;
  nodejs = nodejs_24;

  src = fetchFromGitHub {
    owner = "dataelement";
    repo = "dsh-desktop";
    rev = "78310787e741d516cb3a42a8d77cafd5ae4e34de";
    hash = "sha256-95rq9mOiRU+pz8/GtmXiUa2QyZy5ziyUPTKVrGJ6qDE=";
  };
  npmDepsHash = "sha256-PyU+RIi1DoSkzMO87cr/MjhU8fh8JMAUT9M6+2U5kyI=";
  npmRebuildFlags = [ "--ignore-scripts" ];

  postPatch = ''
    sed -i 's|https://registry.npmmirror.com/|https://registry.npmjs.org/|g' package-lock.json

    # The upstream offline Office runtime has no Linux target.
    sed -i '/^# Offline Office authoring/,$d' build/dsh-desktop.patch.yml

    # The upstream desktop release service only accepts macOS and Windows.
    substituteInPlace src/main/desktop-service/index.ts \
      --replace-fail 'if (!app.isPackaged || service) return' \
                     "if (process.platform === 'linux' || !app.isPackaged || service) return"
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    wrapGAppsHook3
  ];
  buildInputs = [
    glib
    gtk3
    gtk4
    gsettings-desktop-schemas
    stdenv.cc.cc.lib
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "dsh-desktop";
      desktopName = "DSH Desktop";
      exec = "dsh-desktop";
      icon = "dsh-desktop";
      categories = [ "Development" ];
    })
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  dontNpmBuild = true;
  buildPhase = ''
    runHook preBuild

    npm version --no-git-tag-version --ignore-scripts ${version}
    node_modules/.bin/patch-package --error-on-fail
    node scripts/install-brand-assets.mjs
    npm run ppt:build
    node_modules/.bin/electron-vite build

    # These alternatives are for musl, while NixOS uses glibc.
    rm -rf node_modules/@deepseek-ai/node-addon-system-linux-x64/bin/musl
    rm -rf node_modules/@koromix/koffi-linux-x64/musl_x64

    cat > electron-builder.nixos.cjs <<'EOF'
    const { build } = require('./package.json')
    const { verifyAsarUnpack } = require('./scripts/verify-asar-unpack.cjs')

    module.exports = {
      ...build,
      electronDist: '${electron.dist}',
      extraResources: build.extraResources.filter(({ from }) => from !== '.build/office-runtime'),
      afterPack: ({ appOutDir }) => verifyAsarUnpack(appOutDir + '/resources'),
      linux: { target: 'dir', executableName: 'dsh-desktop', icon: 'build/icon.png' }
    }
    EOF
    node_modules/.bin/electron-builder --linux --dir --publish never --config electron-builder.nixos.cjs

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/libexec" "$out/bin"
    cp -a dist/linux-unpacked "$out/libexec/dsh-desktop"
    iconDir="$out/share/icons/hicolor/512x512/apps"
    mkdir -p "$iconDir"
    node --input-type=module -e \
      'import sharp from "sharp"; await sharp("build/icon.png").resize(512, 512).toFile(process.argv[1]);' \
      "$iconDir/dsh-desktop.png"
    runHook postInstall
  '';

  dontWrapGApps = true;
  dontStrip = true;
  dontPatchELF = true;
  dontAutoPatchelf = true;

  preFixup = ''
    makeWrapper "$out/libexec/dsh-desktop/dsh-desktop" "$out/bin/dsh-desktop" \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  postFixup = ''
    autoPatchelf "$out/libexec/dsh-desktop/resources/app.asar.unpacked"
  '';

  meta = {
    description = "Desktop client for DeepSeek Harness";
    homepage = "https://github.com/dataelement/dsh-desktop";
    license = lib.licenses.mit;
    mainProgram = "dsh-desktop";
    platforms = [ "x86_64-linux" ];
  };
}
