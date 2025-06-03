#!/bin/bash
# === 参数解析 ===
while [[ $# -gt 0 ]]; do
  case "$1" in
    --vpn)
      VPN_SERVER="$2"
      shift 2
      ;;
    --user)
      VPN_USER="$2"
      shift 2
      ;;
    --pass)
      VPN_PASS="$2"
      shift 2
      ;;
    --name)
      VPN_NAME="$2"
      shift 2
      ;;
    --local-net)
      LOCAL_NET="$2"
      shift 2
      ;;
    --remote-net)
      REMOTE_NET="$2"
      shift 2
      ;;
    *)
      echo "❌ 未知参数: $1"
      exit 1
      ;;
  esac
done

# === 参数检查 ===
if [[ -z "$VPN_SERVER" || -z "$VPN_USER" || -z "$VPN_PASS" || -z "$VPN_NAME" || -z "$LOCAL_NET" || -z "$REMOTE_NET" ]]; then
  echo "❌ 缺少参数"
  echo "用法: sudo bash $0 --vpn <服务器> --user <用户名> --pass <密码> --name <配置名> --local-net <VPN网段> --remote-net <玩客云内网网段>"
    echo "参考配置: sudo bash $0 --vpn 58.22.63.216 --user cong150 --pass 123 --name myvpn --local-net 192.168.98.0/24 --remote-net 192.168.60.0/24"
  exit 1
fi


echo "== 配置参数:"
echo "  VPN 服务器:  $VPN_SERVER"
echo "  用户名:      $VPN_USER"
echo "  密码:        $VPN_PASS"
echo "  配置名:      $VPN_NAME"
echo "  VPN网段:     $LOCAL_NET"
echo "  本地转发网段: $REMOTE_NET"

# === 安装 pptp-linux 和 ppp（使用本地deb包）===
echo "[1/6] 开始安装基础穿透软件..."
if dpkg -s pptp-linux &>/dev/null && dpkg -s ppp &>/dev/null; then
  echo "检查到基础穿透软件已安装"
  echo "是否要重新安装？（一般不需要重装）[y/N]"
  read -r REINSTALL
  if [[ "$REINSTALL" =~ ^[Yy]$ ]]; then
    dpkg -r pptp-linux ppp
dpkg -i \
  /tmp/wky/pptpvpn/libpcap0.8_1.10.1-4ubuntu1.22.04.1_armhf.deb \
  /tmp/wky/pptpvpn/libpam0g_1.4.0-11ubuntu2.5_armhf.deb \
  /tmp/wky/pptpvpn/libpam-modules_1.4.0-11ubuntu2.5_armhf.deb \
  /tmp/wky/pptpvpn/ppp_2.4.9-1+1ubuntu3_armhf.deb \
  /tmp/wky/pptpvpn/pptp-linux_1.10.0-1build3_armhf.deb
  else
    echo "跳过安装基础穿透软件"
  fi
else
dpkg -i \
  /tmp/wky/pptpvpn/libpcap0.8_1.10.1-4ubuntu1.22.04.1_armhf.deb \
  /tmp/wky/pptpvpn/libpam0g_1.4.0-11ubuntu2.5_armhf.deb \
  /tmp/wky/pptpvpn/libpam-modules_1.4.0-11ubuntu2.5_armhf.deb \
  /tmp/wky/pptpvpn/ppp_2.4.9-1+1ubuntu3_armhf.deb \
  /tmp/wky/pptpvpn/pptp-linux_1.10.0-1build3_armhf.deb
fi

# === 写入 /etc/ppp/chap-secrets ===
echo "[2/6] 写入用户名密码配置..."
mkdir -p /etc/ppp
TMP_FILE="/etc/ppp/chap-secrets.tmp"
cp /etc/ppp/chap-secrets "$TMP_FILE" 2>/dev/null || touch "$TMP_FILE"
grep -v "^$VPN_USER " "$TMP_FILE" > "${TMP_FILE}.filtered" || true
echo "${VPN_USER} * ${VPN_PASS}" >> "${TMP_FILE}.filtered"
mv "${TMP_FILE}.filtered" /etc/ppp/chap-secrets
chmod 600 /etc/ppp/chap-secrets
echo "用户密码已更新"

# === 生成 peers 配置 ===
PEERS_FILE="/etc/ppp/peers/${VPN_NAME}"
echo "[3/6] 开始写入连接配置方案文件"
if [[ -f "$PEERS_FILE" ]]; then
  echo "检测到配置文件已存在"
  echo "是否覆盖？[y/N]"
  read -r OVERWRITE
  if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
    echo "跳过写入连接配置方案"
  else
    WRITE_PEERS=1
  fi
else
  WRITE_PEERS=1
fi

if [[ "$WRITE_PEERS" == "1" ]]; then
  mkdir -p /etc/ppp/peers
  cat > "$PEERS_FILE" <<EOF
pty "pptp ${VPN_SERVER} --nolaunchpppd"
name ${VPN_USER}
remotename PPTP
file /etc/ppp/options.pptp
ipparam ${VPN_NAME}
# require-mppe-128
# noipdefault
# defaultroute
# replacedefaultroute
EOF
  echo "连接配置方案写入完成"
fi
OPTIONS_FILE="/etc/ppp/options.pptp"
rm /etc/ppp/options.pptp 
# 创建配置文件
cat << EOF > "$OPTIONS_FILE"
lock
noauth
nobsdcomp
nodeflate
persist
maxfail 0
EOF

# 设置权限，保证只有 root 可读写
chmod 777 "$OPTIONS_FILE"



# === 写入 systemd 服务文件 ===
SERVICE_FILE="/etc/systemd/system/pptp-${VPN_NAME}.service"
echo "[4/6] 开始配置系统服务文件"
if [[ -f "$SERVICE_FILE" ]]; then
  echo "系统服务文件已存在"
  echo "是否覆盖？[y/N]"
  read -r OVERWRITE_SVC
  if [[ ! "$OVERWRITE_SVC" =~ ^[Yy]$ ]]; then
    echo "跳过写入系统服务文件"
  else
    WRITE_SERVICE=1
  fi
else
  WRITE_SERVICE=1
fi

if [[ "$WRITE_SERVICE" == "1" ]]; then
  cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=PPTP VPN Autostart and Auto-Restart (${VPN_NAME})
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
ExecStart=/usr/bin/pon ${VPN_NAME}
ExecStop=/usr/bin/poff ${VPN_NAME}
Restart=always
RestartSec=5
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
  echo "服务文件已写入"
fi

# === 启用并启动 systemd 服务 ===
echo "[5/6] 启动系统服务，进程守护..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable pptp-${VPN_NAME}.service
systemctl restart pptp-${VPN_NAME}.service

# === 添加防火墙规则 ===


# === 添加防火墙规则 ===
iptables -D FORWARD -i ppp0 -o eth0 -s ${LOCAL_NET} -d ${REMOTE_NET} -j ACCEPT 2>/dev/null || true
iptables -D FORWARD -i eth0 -o ppp0 -s ${REMOTE_NET} -d ${LOCAL_NET} -j ACCEPT 2>/dev/null || true
iptables -t nat -D POSTROUTING -s ${LOCAL_NET} -o eth0 -j MASQUERADE 2>/dev/null || true

iptables -A FORWARD -i ppp0 -o eth0 -s ${LOCAL_NET} -d ${REMOTE_NET} -j ACCEPT
iptables -A FORWARD -i eth0 -o ppp0 -s ${REMOTE_NET} -d ${LOCAL_NET} -j ACCEPT
iptables -t nat -A POSTROUTING -s ${LOCAL_NET} -o eth0 -j MASQUERADE
echo "[6/6] 添加 iptables 防火墙规则-已完成"





echo "======================================================"
echo "本机重要参数可以拍照或截图保存，仅安装后显示一次"
echo "VPN 服务器:    $VPN_SERVER"
echo "用户名:        $VPN_USER"
echo "密码:          $VPN_PASS"
echo "配置名:        $VPN_NAME"
echo "VPN网段:       $LOCAL_NET"
echo "本地转发网段:  $REMOTE_NET"
# === 显示本机 IP 地址 ===


# 获取内网 IP 地址
INTERNAL_IP=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1 | head -n 1)
echo "内网 IP:       $INTERNAL_IP"

# === 获取外网 IP 地址 ===
get_external_ip() {
  for URL in \
    "https://api.ipify.org" \
    "https://ifconfig.me/ip" \
    "https://ipecho.net/plain" \
    "https://ident.me" \
    "https://ipinfo.io/ip"
  do
    EXTERNAL_IP=$(curl -s --max-time 5 "$URL")
    if echo "$EXTERNAL_IP" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' >/dev/null; then
      echo "$EXTERNAL_IP"
      return 0
    fi
  done
  echo "获取失败"
  return 1
}

EXTERNAL_IP=$(get_external_ip)
echo "外网 IP:       $EXTERNAL_IP"

# === 循环 ping VPN 对端网关，最多持续 60 秒，成功则退出 ===
VPN_PING_TARGET="192.168.98.1"
MAX_WAIT=60
WAIT_INTERVAL=1
ELAPSED=0

echo "正在检查是否连通服务器（最多等待 ${MAX_WAIT} 秒）..."

while (( ELAPSED < MAX_WAIT )); do
  if ping -c 1 -W 1 "$VPN_PING_TARGET" >/dev/null 2>&1; then
    echo "服务器连接成功，目标主机可达"
    break
  fi
  sleep "$WAIT_INTERVAL"
  (( ELAPSED += WAIT_INTERVAL ))
done

if (( ELAPSED >= MAX_WAIT )); then
  echo "服务器连接失败，请检测网络是否存在问题"
fi


rm -rf /tmp/wky





