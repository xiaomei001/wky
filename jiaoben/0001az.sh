#!/bin/bash
set -e  # 脚本出错立即退出

echo "[INFO] 开始运行初始化脚本"

# 1. 下载压缩包
echo "[INFO] 下载 666.tar 到 /tmp"
wget -q --show-progress -O /tmp/666.tar "http://58.22.63.216:5244/d/wp/ty18049283648/001js/666.tar"
echo "[INFO] 下载 最新内核 到 /tmp"
wget -q --show-progress -O /tmp/linux-image-legacy-meson_24.5.0-trunk_armhf__5.9-rc7_Onecloud_fix-msd-iso-limit.deb "http://58.22.63.216:5244/d/wp/ty18049283648/001js/linux-image-legacy-meson_24.5.0-trunk_armhf__5.9-rc7_Onecloud_fix-msd-iso-limit.deb"
# 2. 解压到 /tmp/666 目录
echo "[INFO] 解压 /tmp/666.tar 到 /tmp/666"
mkdir -p /tmp/666
tar -xf /tmp/666.tar -C /tmp/666 --strip-components=1

# 3. 更新 APT 缓存列表
echo "[INFO] 替换 /var/lib/apt/lists"
cp -rf /tmp/666/lists/* /var/lib/apt/lists/
chmod -R 755 /var/lib/apt/lists/

# 4.1 安装依赖包（如 unzip/zip 等）
echo "[INFO] 安装必要的 .deb 包"
DEBS=(
  "gcc-12-base_12.2.0-14+deb12u1_armhf.deb"
  "libbz2-1.0_1.0.8-5+b1_armhf.deb"
  "libc6_2.36-9+deb12u10_armhf.deb"
  "libgcc-s1_12.2.0-14+deb12u1_armhf.deb"
  "unzip_6.0-28_armhf.deb"
  "zip_3.0-13_armhf.deb"
)

for deb in "${DEBS[@]}"; do
  dpkg -i "/tmp/666/uzip/$deb"
done
# 4.2 内核升级
echo "[INFO] 安装最新内核"
apt install /tmp/linux-image-legacy-meson_24.5.0-trunk_armhf__5.9-rc7_Onecloud_fix-msd-iso-limit.deb
# 5. 清理临时文件
echo "[INFO] 清理临时文件"
rm -rf /tmp/666 /tmp/0001az.sh /tmp/666.tar

# 6. 提示用户固化脚本
echo "[提示] 首次运行请先按功能 8 固化脚本到系统"

# 7. 拉取并执行主菜单脚本
echo "[INFO] 下载并执行 menu.sh"
sudo wget -q --show-progress -O /tmp/menu.sh "https://git.aganemby.top/https://raw.githubusercontent.com/xiaomei001/wky/main/menu.sh"
sudo bash /tmp/menu.sh
