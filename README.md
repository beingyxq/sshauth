# 🚀 一键 Linux 用户初始化与 SSH 加固脚本

该脚本用于自动化配置 Linux 服务器环境。它能一键完成用户创建、权限分配、SSH 公钥部署以及 SSH 服务加固（随机端口、禁止密码登录）。

## 🛠 功能特性

- **参数化运行**：支持在执行时直接传入用户名和密码。
    
- **用户管理**：自动创建用户并配置 `sudo` 免密权限。
    
- **SSH 加固**：
    
    - 自动从 GitHub 下载公钥配置登录。
        
    - **随机生成** SSH 端口（范围：10000-60000），降低扫描攻击。
        
    - 禁止 Root 用户直接登录。
        
    - 强制使用 SSH Key 认证，**彻底禁用密码登录**。
        
- **安全保护**：执行前自动备份 `sshd_config`，出错自动回滚。
    

## 🚀 快速使用

请将下面命令中的 `yourname` 和 `yourpassword` 替换为你实际想要设置的内容。

Bash

```
curl -sSL https://raw.githubusercontent.com/beingyxq/sshauth/main/setup_user.sh | sudo bash -s -- yourname yourpassword
```

> **注意**：执行后请根据脚本输出的 **随机端口号** 重新连接服务器。

## 📋 脚本逻辑说明

1. **用户创建**：使用 `chpasswd` 安全地设置用户初始密码。
    
2. **Sudo 配置**：在 `/etc/sudoers.d/` 目录下创建独立文件，避免污染主配置文件。
    
3. **权限控制**：严格遵循 SSH 要求的 `.ssh (700)` 和 `authorized_keys (600)` 权限规范。
    
4. **服务重启**：修改配置后会自动执行 `sshd -t` 检查语法，确保服务重启不挂掉。
    

## ⚠️ 重要提醒

- **防火墙设置**：脚本修改 SSH 端口后，请务必在云服务器安全组（及系统防火墙如 ufw/nftables）中**放行新端口**。
    
- **不要关闭当前会话**：在脚本运行结束后，请务必**先新开一个终端测试**是否能成功连接。如果失败，你当前的 root 会话还可以进行修复。
    
- **公钥链接**：记得在脚本中将 `SSH_KEY_URL` 修改为你自己的 GitHub Keys 地址。
    

## 📄 开源协议

[MIT](https://www.google.com/search?q=LICENSE)
