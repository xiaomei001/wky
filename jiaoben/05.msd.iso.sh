#!/bin/bash
ISO_DIR="/var/lib/kvmd/msd"
echo "镜像存储分区剩余空间"
df -h $ISO_DIR | awk 'NR==2 {print $4}'
# 检查目录是否存在
if [ ! -d "$ISO_DIR" ]; then
    echo "目录不存在: $ISO_DIR"
    exit 1
fi
# 查找所有 .iso 文件（只列文件名）
mapfile -t iso_files < <(find "$ISO_DIR" -maxdepth 1 -type f -name "*.iso" -printf "%f\n")

# 如果没有文件，退出
if [ ${#iso_files[@]} -eq 0 ]; then
    echo "未找到任何 ISO 文件。"
    exit 0
fi

# 列出所有文件
echo "发现以下 ISO 文件："
for iso in "${iso_files[@]}"; do
    echo " - $iso"
done

echo
echo "操作选项："
echo "1. 删除指定 ISO 文件"
echo "2. 删除所有 ISO 文件"
echo "3. 退出"
read -p "请选择操作 [1-3]: " choice

case "$choice" in
    1)
        echo
        echo "请选择要删除的 ISO 文件："
        select iso in "${iso_files[@]}" "取消"; do
            if [[ "$iso" == "取消" ]]; then
                echo "操作已取消。"
                break
            elif [[ -n "$iso" && -f "$ISO_DIR/$iso" ]]; then
                rm -f "$ISO_DIR/$iso"
                echo "已删除: $iso"
                break
            else
                echo "无效选择，请重试。"
            fi
        done
        ;;
    2)
        read -p "确认删除所有 ISO 文件？[y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            rm -f "$ISO_DIR"/*.iso
            echo "所有 ISO 文件已删除。"
        else
            echo "操作已取消。"
        fi
        ;;
    3)
        echo "已退出。"
        ;;
    *)
        echo "无效选项。"
        ;;
esac
