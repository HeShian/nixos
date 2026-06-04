# 故障排除

常见问题和解决方案。

**[English](../en/troubleshooting.md)**

---

## 构建因网络问题失败

如果镜像缓慢或返回 SSL 错误：

```bash
# 检查哪个镜像有问题
curl -sL -o /dev/null -w "%{http_code}" https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store/nix-cache-info

# 从 nix/substituters.nix 中移除有问题的镜像
# 然后重启 nix-daemon
sudo systemctl restart nix-daemon
```

## Fetchurl Hash 不匹配

如果下载的文件已更改（例如壁纸图片）：

```bash
# 获取正确的 hash
nix-prefetch-url <URL>

# 在对应的 .nix 文件中更新 hash
```

## 代理不工作

```bash
# 检查 mihomo 是否运行
systemctl --user status mihomo

# 检查 7890 端口是否监听
ss -tlnp | grep 7890

# 重启 mihomo
systemctl --user restart mihomo
```

## NVIDIA GPU 未检测到

```bash
# 检查 nvidia 模块是否加载
lsmod | grep nvidia

# 检查 nvidia-smi
nvidia-smi

# 如果不工作，验证 hosts/<主机名>/os.nix 中的总线 ID 是否正确
# 查找你的总线 ID：
lspci | grep -E "VGA|3D"
```

## 输入法不工作

```bash
# 检查 fcitx5 状态
fcitx5-diagnose

# 确保环境变量已设置
echo $XMODIFIERS  # 应为 @im=fcitx
echo $GTK_IM_MODULE
echo $QT_IM_MODULE

# 重启 fcitx5
systemctl --user restart fcitx5-daemon
```

## 启动加载器问题

如果从 systemd-boot 切换后 GRUB 未显示：

```bash
# 手动安装 GRUB
sudo $(find /nix/store -name "grub-install" -type f | head -1) \
  --target=x86_64-efi \
  --efi-directory=/boot \
  --bootloader-id=NixOS \
  --recheck

# 设置 GRUB 为首选启动项
sudo $(find /nix/store -name "efibootmgr" -type f | head -1) -o 0002,0001
```

## 密钥无法解密

```bash
# 检查你的 SSH 密钥是否被授权
cat ~/.ssh/id_ed25519.pub

# 验证它与 secrets/secrets.nix 中的密钥匹配

# 测试解密
age -d -i ~/.ssh/id_ed25519 secrets/mimo_token.age
```

## Home Manager 激活失败

如果现有文件冲突：

```bash
# 备份冲突文件
mv ~/.config/fish/config.fish ~/.config/fish/config.fish.bak

# 重试
nh home switch
```

## Flake 评估错误

如果看到 `experimental Nix feature 'pipe-operators' is disabled`：

```bash
# 确保 /etc/nixos/configuration.nix 中启用了 pipe-operators
nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
sudo nixos-rebuild switch
```

如果看到 `Path '...' in the repository is not tracked by Git`：

```bash
# 将新文件添加到 git
git add -A
```
