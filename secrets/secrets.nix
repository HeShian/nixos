let
  claudia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGwU3oxC8krk+KNmGIQfUe8NUE9u623M4wSz+JRVWEB1 claudia@acer";
  publicKeys = [ claudia ] ++ (map (host: host.publicKey) (import ../hosts/hosts.nix));
  secrets = [
    "mimo_token"
    "nix_github_token"
    "clash_subscription_url"
  ];
in
builtins.listToAttrs (
  map (secret: {
    name = "${secret}.age";
    value = { inherit publicKeys; };
  }) secrets
)
