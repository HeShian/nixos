{
  den.aspects.networking = { host, ... }: {
    nixos = {
      networking.networkmanager.enable = true;
      services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ host.defaultUser ];
      };
    };
      programs.clash-verge = {
    enable = true;
    serviceMode = true;
    tunMode = true;
    group = "users";
  };
    };
  };

  # Host 单独选择的代理环境。
  den.aspects.proxy.nixos.environment.variables = {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = "http://127.0.0.1:7897";
    # Clash 的混合端口同时支持 HTTP 与 SOCKS5，这里统一用 HTTP：
    # all_proxy 设成 socks5 时，httpx 会在构造客户端时实例化 SOCKS transport，
    # 未装 socksio 就直接 ImportError（如 uvx mcp-nixos、fastmcp 系工具）。
    all_proxy = "http://127.0.0.1:7897";
  };

}
