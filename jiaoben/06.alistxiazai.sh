#!/bin/bash
set -e

LIST_URL="http://58.22.63.216:5244/d/home/%E8%84%9A%E6%9C%AC/xiazai.txt"
TARGET_DIR="/var/lib/kvmd/msd"
TMP_LIST="/tmp/xiazai.txt"

# 检查目标目录
if [[ ! -d "$TARGET_DIR" || ! -w "$TARGET_DIR" ]]; then
    echo "错误：目标目录不存在或不可写：$TARGET_DIR"
    exit 1
fi

# 下载远程列表文件
echo "正在获取下载列表..."
if ! curl -fsSL "$LIST_URL" -o "$TMP_LIST"; then
    echo "下载列表失败：$LIST_URL"
    exit 1
fi

# 读取有效 URL（过滤空行和注释）
mapfile -t URLS < <(grep -E '^https?://' "$TMP_LIST" | sed '/^\s*$/d')

if [[ ${#URLS[@]} -eq 0 ]]; then
    echo "列表中未发现可用链接"
    exit 0
fi

# 显示文件列表
echo "下载文件列表："
for i in "${!URLS[@]}"; do
    filename=$(basename "${URLS[$i]}")
    printf "%2d)  %s\n" $((i+1)) "$filename"
done

echo
read -p "请输入要下载的编号（空格分隔，或输入 all 下载全部）: " CHOICE

# 下载函数
download() {
    local url="$1"
    local name
    name=$(basename "$url")
    echo "下载: $name"
    wget -q --show-progress -O "$TARGET_DIR/$name" "$url"
    echo "完成: $name"
    echo
}

# 下载逻辑
if [[ "$CHOICE" == "all" ]]; then
    for url in "${URLS[@]}"; do
        download "$url"
    done
else
    for idx in $CHOICE; do
        if [[ "$idx" =~ ^[0-9]+$ && "$idx" -ge 1 && "$idx" -le ${#URLS[@]} ]]; then
            download "${URLS[$((idx-1))]}"
        else
            echo "无效编号: $idx"
        fi
    done
fi
