#!/bin/bash

echo "开始卸载 pptp-linux、ppp 及其依赖..."

# 强制停止相关 VPN 服务
systemctl stop pptp-*.service 2>/dev/null
systemctl disable pptp-*.service 2>/dev/null

# 卸载核心软件包
apt-get purge -y pptp-linux ppp

# 自动清理未使用的依赖
apt-get autoremove --purge -y

# 清理多余缓存和残留配置
apt-get clean
rm -rf /etc/ppp
rm -rf /var/log/ppp*
rm -f /etc/ppp/peers/*
rm -f /etc/ppp/chap-secrets
rm -f /etc/ppp/pap-secrets
rm -f /etc/systemd/system/pptp-myvpn.service
echo "检查是否有残留库..."
dpkg -l | grep -E 'pptp|ppp|libpcap|libpam' && echo "⚠️ 存在残留包，请手动确认是否需要清除。"

echo "卸载完成。建议重启系统以确保内核路由和模块刷新。"
