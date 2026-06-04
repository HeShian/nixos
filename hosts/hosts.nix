[
  {
    host = "acer";
    user = "claudia";
    extraOSModules = [ ./acer/os.nix ];
    extraHomeModules = [ ./acer/home.nix ];
    extraHomeArgs = {
      nixosVersion = "unstable";
      homeManagerVersion = "master";
    };
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGwU3oxC8krk+KNmGIQfUe8NUE9u623M4wSz+JRVWEB1 claudia@acer";
  }
]
