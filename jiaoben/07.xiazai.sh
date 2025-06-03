#!/bin/bash
set -e

TARGET_DIR="/var/lib/kvmd/msd"

# 检查下载目录是否存在和可写
if [[ ! -d "$TARGET_DIR" || ! -w "$TARGET_DIR" ]]; then
    echo "目录不存在或不可写: $TARGET_DIR"
    exit 1
fi

while true; do
    # 获取下载链接
    read -p "请输入 ISO 下载链接: " URL
    [[ -z "$URL" ]] && echo "链接不能为空，请重新输入。" && continue

    # 获取文件名
    read -p "请输入保存文件名（不加 .iso 后缀）: " FILENAME
    [[ -z "$FILENAME" ]] && echo "文件名不能为空，请重新输入。" && continue

    # 拼接完整保存路径
    OUTPUT="${TARGET_DIR}/${FILENAME}.iso"

    # 显示确认信息
    echo
    echo "即将下载："
    echo "下载链接: $URL"
    echo "保存路径: $OUTPUT"
    echo

    # 询问是否确认
    read -p "确认开始下载吗？(y/n): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "正在下载，请稍候..."
        wget -O "$OUTPUT" "$URL"
        echo "下载完成: $OUTPUT"
        break
    else
        echo "已取消，本轮重新输入。"
        echo
    fi
done
