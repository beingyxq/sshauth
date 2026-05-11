#!/bin/bash

# ==========================================================
# 脚本功能：传参创建用户、配置 SSH Key、加固 SSH 服务
# 使用方法：sudo ./setup_user.sh [用户名] [密码]
# ==========================================================

# 1. 参数检查
IF_USER=$1
IF_PASS=$2

if [ -z "$IF_USER" ] || [ -z "$IF_PASS" ]; then
    echo "错误：缺少参数！"
    echo "用法: sudo $0 <用户名> <密码>"
    exit 1
fi

SSH_KEY_URL="https://github.com/beingyxq/sshauth/raw/refs/heads/main/authorized_keys"
SSHD_CONFIG="/etc/ssh/sshd_config"

# 2. 权限检查
if [ "$EUID" -ne 0 ]; then
  echo "错误：请使用 root 权限运行。"
  exit 1
fi

echo "正在处理用户: $IF_USER ..."

# 3. 创建用户并设置密码
if id "$IF_USER" &>/dev/null; then
    echo "提示：用户 $IF_USER 已存在。"
else
    # 创建用户
    useradd -m -s /bin/bash "$IF_USER"
    # 修改密码 (通过 chpasswd 批量处理更安全)
    echo "$IF_USER:$IF_PASS" | chpasswd
    echo "用户 $IF_USER 创建并设置密码成功。"
fi

# 4. 授予 sudo 权限并配置免密 (可选)
# 如果你希望 sudo 时仍需输入刚才设置的密码，请删除下面这行
echo "$IF_USER ALL=(ALL) ALL" > "/etc/sudoers.d/$IF_USER"
chmod 440 "/etc/sudoers.d/$IF_USER"

# 5. 配置 SSH Key
USER_HOME=$(eval echo "~$IF_USER")
mkdir -p "$USER_HOME/.ssh"
curl -fsSL "$SSH_KEY_URL" -o "$USER_HOME/.ssh/authorized_keys"
chmod 700 "$USER_HOME/.ssh"
chmod 600 "$USER_HOME/.ssh/authorized_keys"
chown -R "$IF_USER":"$IF_USER" "$USER_HOME/.ssh"

# 6. SSH 服务加固 (随机端口)
RANDOM_PORT=$(shuf -i 10000-60000 -n 1)
cp "$SSHD_CONFIG" "$SSHD_CONFIG.bak"

sed -i "s/^#\?Port .*/Port $RANDOM_PORT/" "$SSHD_CONFIG"
sed -i "s/^#\?PermitRootLogin .*/PermitRootLogin no/" "$SSHD_CONFIG"
sed -i "s/^#\?PasswordAuthentication .*/PasswordAuthentication no/" "$SSHD_CONFIG"
sed -i "s/^#\?PubkeyAuthentication .*/PubkeyAuthentication yes/" "$SSHD_CONFIG"

# 7. 重启服务
sshd -t && systemctl restart sshd

echo "------------------------------------------------"
echo "部署完成！"
echo "用户名: $IF_USER"
echo "密码 (用于 sudo): $IF_PASS"
echo "SSH 端口: $RANDOM_PORT"
echo "重要：请在当前窗口关闭前，测试新端口能否连接！"
echo "重要：建议运行 history -c 清除当前会话历史"
echo "------------------------------------------------"
