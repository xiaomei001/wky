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