#!/bin/bash
set -e

echo "Установка зависимостей..."
sudo apt-get update -y
sudo apt-get install -y \
    git-core gnupg flex bison build-essential zip \
    zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
    lib32ncurses5-dev lib32z1-dev x11proto-core-dev \
    libx11-dev libgl1-mesa-dev libxml2-utils xsltproc \
    unzip fontconfig python3 rsync curl ccache repo p7zip-full \
    imagemagick bc gperf

echo "Настройка окружения..."
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 50G

echo "Инициализация репозитория TWRP..."
if [ ! -d "platform_manifest_twrp_omni" ]; then
    git clone https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-12.1
fi
cd platform_manifest_twrp_omni

repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-12.1
repo sync -j$(nproc) --force-sync --no-clone-bundle --no-tags

echo "Клонирование дерева устройства..."
if [ ! -d "device/xiaomi/angelican" ]; then
    git clone https://github.com/Edmond2007/android_device_xiaomi_angelican.git -b twrp-12.1 device/xiaomi/angelican
fi

echo "Запуск сборки..."
source build/envsetup.sh
lunch omni_angelican-eng
mka recoveryimage -j$(nproc)

echo "Создание архива..."
cd out/target/product/angelican
if [ -f "recovery.img" ]; then
    zip -r9 "TWRP_angelican_$(date +%Y%m%d).zip" recovery.img
    echo "Сборка успешно завершена!"
    echo "Артефакт: $(pwd)/TWRP_angelican_$(date +%Y%m%d).zip"
else
    echo "Ошибка: recovery.img не найден!"
    exit 1
fi
