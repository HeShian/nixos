{ den, ... }:
{
  den.aspects.user-vm = {
    includes = [
      den.batteries.define-user
      den.batteries.host-aspects
      den.batteries.primary-user
      (den.batteries.user-shell "fish")
    ];

    user.description = "user-vm";

    # 与 claudia 同一身份：VM 里提交到同一仓库时署名一致，且不暴露真实邮箱。
    homeManager.programs.git.settings.user = {
      name = "claudia";
      email = "96305135+HeShian@users.noreply.github.com";
    };
  };
}
