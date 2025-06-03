#!/bin/bash

# 脚本必须在 root 权限下运行
if [ "$(id -u)" -ne 0 ]; then
    echo "错误：本脚本必须以 root 权限运行。"
    echo "请使用 sudo 或以 root 用户身份执行。"
    exit 1
fi

# 设置选项菜单
show_menu() {
    clear
    echo "==== 管理工具菜单 ===="
    echo "1. 安装 PPTP"
    echo "2. 安装 NPS"
    echo "3. 检查服务器连接情况"
    echo "4. 显示本机 IP"
    echo "5. 卸载"
    echo "0. 退出"
    echo "======================"
    echo -n "请输入选项 [0-5]: "
}

while true; do
    show_menu
    read -r choice
    case "$choice" in
        1)
            bash install_pptp.sh
            ;;
        2)
            bash install_nps.sh
            ;;
        3)
            bash check_server.sh
            ;;
        4)
            bash show_ip.sh
            ;;
        5)
            bash uninstall.sh
            ;;
        0)
            echo "退出程序。"
            exit 0
            ;;
        *)
            echo "无效选项，请重新输入。"
            sleep 1
            ;;
    esac
done
