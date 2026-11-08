{ den, ... }:
{
  den.aspects.user-vm = {
    includes = [ den.batteries.define-user den.batteries.host-aspects ];

    user = {
      extraGroups = [ "wheel" "networkmanager" ];
      initialHashedPassword = "$6$8KoDFVFh4c8KVqdp$gYWw2ag4YtstUphwAV9E1S3Q1HiKZVZ54DwhF9FyoBMHB6sDJdeNz5tke9ANJWS1zcgALKWSyhboMDKxddPXD0";
    };

    homeManager.home.stateVersion = "26.05";
  };
}
