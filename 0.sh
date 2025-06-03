#!/bin/bash

set -e

URL="http://58.22.63.216:5244/d/home/%E8%84%9A%E6%9C%AC/wky/wky.tar.gz"     #下载文件云地址
DEST="/tmp/wky.tar.gz"              #下载文件本地地址
EXTRACT_DIR="/tmp"          #解压地址
SCRIPT_PATH="/tmp/wky/1.sh"       #脚本地址
#执行命令
EXEC_CMD="sudo bash $SCRIPT_PATH --vpn 58.22.63.216 --user cong050 --pass 123 --name myvpn --local-net 192.168.98.0/24 --remote-net 192.168.60.0/24"

echo "📥 正在下载 wky.tar.gz ..."
wget -O "$DEST" "$URL"

echo "📂 解压缩到 $EXTRACT_DIR ..."
tar -xzf "$DEST" -C "$EXTRACT_DIR"

if [[ -f "$SCRIPT_PATH" ]]; then
  echo "🚀 运行脚本: $EXEC_CMD"
  chmod +x "$SCRIPT_PATH"
  eval "$EXEC_CMD"
else
  echo "❌ 未找到脚本: $SCRIPT_PATH"
  exit 1
fi
rm -f "$DEST"