#!/bin/bash

#加回部分设备支持
if [[ $WRT_URL == *"immortalwrt"* && $WRT_TARGET == "Mediatek" ]]; then
	cp -rf ./Patches/mediatek/*.dts ./wrt/target/linux/mediatek/dts/
	patch -R -p1 -d ./wrt < ./Patches/mediatek/*.patch

	echo "$WRT_TARGET patch has been installed!"
fi

if [ $WRT_TARGET == "Rockchip" ]; then
	sed -i '/^UBOOT_TARGETS := rk3528-evb rk3588-evb/s/^/#/' package/boot/uboot-rk35xx/Makefile

	echo "$WRT_TARGET patch has been installed!"
fi