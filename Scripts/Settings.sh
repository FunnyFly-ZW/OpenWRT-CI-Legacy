#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" $CFG_FILE
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" $CFG_FILE
#设置密码为空
sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings
#x86只显示CPU型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore
#修复rk35xx
sed -i '/^UBOOT_TARGETS := rk3528-evb rk3588-evb/s/^/#/' package/boot/uboot-rk35xx/Makefile
#修改重启菜单位置
sed -i 's/\(entry({"admin", "system", "reboot".*\), 90)/\1, 98)/' feeds/luci/modules/luci-mod-admin-full/luasrc/controller/admin/system.lua

if [[ $WRT_URL == *"lede"* ]]; then
	LEDE_FILE=$(find ./package/lean/autocore/ -type f -name "index.htm")
	#修改默认时间格式
	sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S %A")/g' $LEDE_FILE
	#添加编译日期标识
	sed -i "s/(\(<%=pcdata(ver.luciversion)%>\))/\1 \/ $WRT_REPO-$WRT_DATE/" $LEDE_FILE
	#修改默认WIFI名
	sed -i "s/ssid=.*/ssid=$WRT_WIFI/g" ./package/kernel/mac80211/files/lib/wifi/mac80211.sh
elif [[ $WRT_URL == *"immortalwrt"* ]]; then
	#添加编译日期标识
	VER_FILE=$(find ./feeds/luci/modules/ -type f -name "10_system.js")
	awk -v wrt_repo="$WRT_REPO" -v wrt_date="$WRT_DATE" '{ gsub(/(\(luciversion \|\| \047\047\))/, "& + (\047 / "wrt_repo"-"wrt_date"\047)") } 1' $VER_FILE > temp.js && mv -f temp.js $VER_FILE
	#修改默认WIFI名
	sed -i "s/ssid=.*/ssid=$WRT_WIFI/g" ./package/network/config/wifi-scripts/files/lib/wifi/mac80211.sh
fi

#配置文件修改
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

if [[ $WRT_URL == *"lede"* ]]; then
	echo "CONFIG_PACKAGE_luci-app-ssr-plus=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-openclash=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_Iptables_Transparent_Proxy=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_Nftables_Transparent_Proxy=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Haproxy=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Hysteria=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_NaiveProxy=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Libev_Client=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Libev_Server=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Rust_Client=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Rust_Server=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_Libev_Client=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_Libev_Server=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Simple_Obfs=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_SingBox=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_Plus=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_tuic_client=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray_Geodata=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray_Plugin=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Xray=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Xray_Plugin=y" >> ./.config
elif [[ $WRT_URL == *"immortalwrt"* ]]; then
	echo "CONFIG_PACKAGE_luci=y" >> ./.config
	echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-homeproxy=y" >> ./.config
fi
