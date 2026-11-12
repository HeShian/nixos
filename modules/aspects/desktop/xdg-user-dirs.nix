{
  # XDG 用户目录固定为英文名（Desktop / Documents / Downloads / ...）。
  #
  # 系统 locale 是 zh_CN，xdg-user-dirs-update 首次登录会生成中文目录
  # （桌面/文档/下载/...）。这里交给 home-manager 显式管理：
  #   - 写 ~/.config/user-dirs.dirs（只读，英文路径）
  #   - 写 ~/.config/user-dirs.conf（enabled=False，禁止 xdg-user-dirs-update 改回来）
  #   - createDirectories 在激活时创建缺失目录
  # 已存在的旧中文目录内容已在迁移时手动搬到英文目录。
  den.aspects.xdg-user-dirs.homeManager = {
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
