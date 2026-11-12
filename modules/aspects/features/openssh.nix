{ den, ... }:
{
  den.aspects.openssh = { host, ... }: {
    nixos.services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ host.defaultUser ];
      };
    };
  };
}
