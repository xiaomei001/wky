#!/bin/bash

# 脚本必须在 root 权限下运行
if [ "$(id -u)" -ne 0 ]; then
    echo "错误：本脚本必须以 root 权限运行。"
    echo "请使用 sudo 或以 root 用户身份执行。"
    exit 1
fi
cd /tmp
# wget -O /tmp/wky-main.zip "https://git.aganemby.top/https://github.com/xiaomei001/wky/archive/refs/heads/main.zip"
while true; do
    echo "请选择下载方式："
    echo "1) 主力下载，实时获得更新，优先推荐"
    echo "2) 备用下载，定期手动同步更新"
    read -p "请输入选项 [1-2]: " choice

    case "$choice" in
        1)
            echo "你选择了：海外下载"
            # 示例命令：海外下载链接
            wget -O /tmp/wky-main.zip "https://git.aganemby.top/https://github.com/xiaomei001/wky/archive/refs/heads/main.zip"
            break
            ;;
        2)
            echo "你选择了：海内下载"
            # 示例命令：国内镜像链接
            wget -O /tmp/wky-main.zip "http://wky0.4kmi.vip:5244/d/home/wky/wky-main.zip"
            break
            ;;
        *)
            echo "无效的选项，请重新输入 1 或 2。"
            ;;
    esac
done

unzip -o -q /tmp/wky-main.zip -d /tmp
unzip -o -q /tmp/wky-main/3k01.zip -d /tmp/wky-main/vpnbianhao
# 设置选项菜单
show_menu() {
    clear
    echo "==== 管理工具菜单 ============"
    echo "1. 安装客户端"
    echo "2. 卸载客户端"
    echo "3. 检查与服务器连接"
    echo "4. 显示本机内外网IP"
    echo "5. 检查空间剩余并删除多余iso"
    echo "6. 从服务器下载新的镜像"
    echo "7. 从网址下载新的镜像"
    echo "8. 固化+升级程序和脚本"
    echo "9. 升级本地的程序和脚本"
    echo "0. 退出"
    echo "=============================="
    echo -n "请输入选项 [0-9]: "
}

while true; do
    show_menu
    read -r choice
    case "$choice" in
        1)
# 循环输入，直到找到对应脚本
while true; do
    
    read -p "请输入脚本编号（例如 001001）: " ID
    TARGET_SCRIPT="/tmp/wky-main/vpnbianhao/${ID}.sh"

    if [[ -f "$TARGET_SCRIPT" ]]; then
        echo "找到脚本: $TARGET_SCRIPT"
        chmod +x "$TARGET_SCRIPT"
        sudo bash "$TARGET_SCRIPT"
        echo "10秒后自动返回主菜单"
        sleep "10"
        break
    else
        echo "未找到脚本: $TARGET_SCRIPT"
        echo "请重新输入正确编号。"
    fi
done
            ;;
        2)
SCRIPT_PATH="/tmp/wky-main/pptpvpn/09uninstall_pptp.sh"
# 检查脚本是否存在
if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "未找到脚本: $SCRIPT_PATH"
    exit 1
fi
# 提示用户确认
read -p "是否确认卸载客户端？(y/N): " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    echo "正在执行卸载脚本..."
    sudo bash "$SCRIPT_PATH"
else
    echo "已取消卸载。"
fi
            echo "10秒后自动返回主菜单"
        sleep "10"
            ;;
        3)
        sudo bash /tmp/wky-main/jiaoben/03.ping.sh
        echo "10秒后自动返回主菜单"
        sleep "10"
            ;;
        4)
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
  echo "获取外网IP失败，请检查网络是否正常"
  return 1
}
EXTERNAL_IP=$(get_external_ip)
echo "外网 IP:       $EXTERNAL_IP"
        echo "6秒后自动返回主菜单"
        sleep "6"
            ;;
        5)
            sudo bash /tmp/wky-main/jiaoben/05.msd.iso.sh
                    echo "3秒后自动返回主菜单"
        sleep "3"
            ;;
        6)
            sudo bash /tmp/wky-main/jiaoben/06.alistxiazai.sh
                        echo "3秒后自动返回主菜单"
            sleep "3"
            ;;
        7)
            sudo bash /tmp/wky-main/jiaoben/07.xiazai.sh
            echo "5秒后自动返回主菜单"
            sleep "5"
            ;;
        8)
            sudo bash /tmp/wky-main/jiaoben/08.guhua.sh
            echo "3秒后自动返回主菜单"
            sleep "3"
            ;;
        9)
            sudo bash /tmp/wky-main/jiaoben/09.senji.sh
            echo "3秒后自动返回主菜单"
            sleep "3"
            ;;
        0)
            rm /tmp/menu.sh
            rm /tmp/wky-main.zip
            rm -rf /tmp/wky-main/
            rm /tmp/xiazai.txt
            echo "退出程序。"
            exit 0
            ;;
        *)
            echo "无效选项，请重新输入。"
            sleep 1
            ;;
    esac
done
