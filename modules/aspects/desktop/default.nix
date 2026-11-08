{ den, ... }:
{
  den.aspects.desktop.includes = with den.aspects; [
    umbriel
    noctalia
    noctalia-greeter
    desktop-fonts
    desktop-audio
    desktop-applications
    desktop-flatpak
    desktop-portals
    desktop-localization
    desktop-terminal
    desktop-scripts
    umbriel-window-rules
  ];
}
