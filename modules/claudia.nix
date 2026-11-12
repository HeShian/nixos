{ den, ... }:
{
  den.aspects.claudia = {
    # define-user：OS 账户 + home 路径；host-aspects：把 host 的共享配置带进来；
    # primary-user：wheel + networkmanager 组；user-shell：登录 shell 与对应程序。
    includes = [
      den.batteries.define-user
      den.batteries.host-aspects
      den.batteries.primary-user
      (den.batteries.user-shell "fish")
    ];

    user.description = "claudia";

    homeManager.programs.git.settings.user = {
      name = "claudia";
      email = "96305135+HeShian@users.noreply.github.com";
    };
  };
}
