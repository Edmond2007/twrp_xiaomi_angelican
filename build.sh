#!/bin/bash
set -e  # Прерывать выполнение при ошибках

# Установка зависимостей
echo "Установка зависимостей..."
sudo apt-get update -y
sudo apt-get install -y \
    git-core gnupg flex bison build-essential zip \
    zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
    lib32ncurses5-dev lib32z1-dev x11proto-core-dev \
    libx11-dev libgl1-mesa-dev libxml2-utils xsltproc \
    unzip fontconfig python3 rsync curl ccache repo p7zip-full \
    imagemagick bc gperf

# Настройка окружения
echo "Настройка окружения..."
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 50G

# Клонирование и инициализация репозитория TWRP
echo "Инициализация репозитория TWRP..."
if [ ! -d "platform_manifest_twrp_omni" ]; then
    git clone https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-12.1
fi
cd platform_manifest_twrp_omni

repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-12.1
repo sync -j$(nproc) --force-sync --no-clone-bundle --no-tags

# Клонирование дерева устройства
echo "Клонирование дерева устройства..."
if [ ! -d "device/xiaomi/angelica" ]; then
    git clone https://github.com/twrpdtgen/android_device_xiaomi_angelica.git device/xiaomi/angelica
fi

# Сборка TWRP
echo "Запуск сборки..."
source build/envsetup.sh
lunch omni_angelica-eng
mka recoveryimage -j$(nproc)

# Архивирование recovery.img
echo "Создание архива..."
cd out/target/product/angelica
if [ -f "recovery.img" ]; then
    zip -r9 "TWRP_angelica_$(date +%Y%m%d).zip" recovery.img
    echo "Сборка успешно завершена!"
    echo "Артефакт: $(pwd)/TWRP_angelica_$(date +%Y%m%d).zip"
else
    echo "Ошибка: recovery.img не найден!"
    exit 1
fi
