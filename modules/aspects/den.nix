{ lib, ... }:
{
  # 所有 host / user 的声明集中在在这里；它们的配置分别在 hosts/<host>.nix 与 users/<user>.nix。
  # 新增机器：这里加声明 + 在 hosts/ 加一个 aspect 文件。

  # acer：宿主机，用户 claudia，dotfiles 用仓库活链接
  den.hosts.x86_64-linux.acer = {
    defaultUser = "claudia";
    users.claudia = { };
  };

  # nixos-vm：虚拟机，用户 user-vm，dotfiles 链到 flake store
  den.hosts.x86_64-linux.nixos-vm = {
    defaultUser = "user-vm";
    users.user-vm = { };
  };

  # 每个用户默认带 user（OS 账户层）与 homeManager 两个 class。
  den.schema.user.classes = lib.mkDefault [ "user" "homeManager" ];
}
