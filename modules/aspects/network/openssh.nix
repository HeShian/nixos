{
  den.aspects.openssh.nixos.services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "user-vm" ];
    };
  };
}
