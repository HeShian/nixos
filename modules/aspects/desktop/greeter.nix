{
  den.aspects.noctalia-greeter.nixos.services.displayManager.noctalia-greeter = {
    enable = true;
    settings = {
      session.default = "umbriel";
      user.default = "user-vm";
    };
  };
}
