{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    clash-meta
    mihomo
  ];

  systemd.user.services.mihomo-subscribe = {
    Unit = {
      Description = "Update mihomo subscription";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.mihomo}/bin/mihomo -f $(cat ${config.age.secrets.clash_subscription_url.path}) -d %h/.config/mihomo'";
    };
  };

  systemd.user.timers.mihomo-subscribe = {
    Unit = {
      Description = "Update mihomo subscription daily";
    };
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
