{
  # 所有 host / user 的声明集中在这里；它们的配置分别在 <host>.nix 与 <user>.nix。
  # 声明与配置分开是 Den 模板（templates/default）的做法：新增机器只改本文件 + 一个 aspect 文件。

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
}
