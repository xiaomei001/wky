
#!/bin/bash
set -e
SCRIPT_PATH="/tmp/wky-main/pptpvpn/02install_pptp.sh"       #脚本地址
#执行命令
EXEC_CMD="sudo bash $SCRIPT_PATH --vpn 58.22.63.216 --user cong040 --pass 123 --name myvpn --local-net 192.168.98.0/24 --remote-net 192.168.10.0/24"
if [[ -f "$SCRIPT_PATH" ]]; then
  echo "运行脚本: $EXEC_CMD"
  chmod +x "$SCRIPT_PATH"
  eval "$EXEC_CMD"
else
  echo "未找到脚本: $SCRIPT_PATH"
  exit 1
fi
