#!/bin/bash

# Установка зависимостей
sudo apt update
sudo apt install -y git bc bison build-essential ccache curl flex g++-multilib gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev openjdk-11-jdk python3 android-tools-adb android-tools-fastboot

# Клонирование репозитория TWRP
git clone https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-12.1
cd platform_manifest_twrp_omni

# Инициализация репозитория
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-12.1
repo sync -j$(nproc) --force-sync --no-clone-bundle --no-tags

# Клонирование дерева устройств для Redmi 9C NFC (пример, нужно найти актуальное)
git clone https://github.com/twrpdtgen/android_device_xiaomi_angelican.git device/xiaomi/angelica

# Запуск сборки
source build/envsetup.sh
lunch omni_angelica-eng
mka recoveryimage -j$(nproc)

# Архивирование готового recovery.img
cd out/target/product/angelica
zip TWRP_angelica_$(date +%Y%m%d).zip recovery.img
