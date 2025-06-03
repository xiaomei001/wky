#!/bin/bash
set -e
rm /opt/wky-main/menu.sh
cp /tmp/wky-main/menu.sh /opt/wky-main/menu.sh
chmod +x /opt/wky-main/menu.sh
echo "更新完成，输入 'wky' 运行菜单脚本。"
