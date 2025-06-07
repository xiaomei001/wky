#!/bin/bash

set -e

# 1. 创建目录并复制脚本
mkdir -p /opt/wky-main
cp -f /tmp/wky-main/menu.sh /opt/wky-main/menu.sh
chmod +x /opt/wky-main/menu.sh

# 2. 创建启动脚本 /usr/local/bin/wky
cat > /usr/local/bin/wky <<'EOF'
#!/bin/bash
# 以root权限执行脚本菜单
if [ "$(id -u)" -ne 0 ]; then
  exec sudo /opt/wky-main/menu.sh
else
  exec /opt/wky-main/menu.sh
fi
EOF

chmod +x /usr/local/bin/wky

echo "安装完成，输入 'wky' 运行菜单脚本。"
