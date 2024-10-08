#!/bin/bash

#更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)

	rm -rf $(find ../feeds/ -type d -iname "*$PKG_NAME*" -prune)

	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	if [[ $PKG_SPECIAL == "pkg" ]]; then
		cp -rf $(find ./$REPO_NAME/ -type d -iname "*$PKG_NAME*" -prune) ./
		rm -rf ./$REPO_NAME
	elif [[ $PKG_SPECIAL == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

#更新主题
#UPDATE_PACKAGE "design" "gngpp/luci-theme-design" "$([[ $WRT_URL == *"lede"* ]] && echo "main" || echo "js")"
#UPDATE_PACKAGE "design-config" "gngpp/luci-app-design-config" "master"
UPDATE_PACKAGE "argon" "jerrykuku/luci-theme-argon" "$([[ $WRT_URL == *"lede"* ]] && echo "18.06" || echo "master")"
UPDATE_PACKAGE "argon-config" "jerrykuku/luci-app-argon-config" "$([[ $WRT_URL == *"lede"* ]] && echo "18.06" || echo "master")"

#科学上网
UPDATE_PACKAGE "passwall" "xiaorouji/openwrt-passwall" "luci-smartdns-dev"
#UPDATE_PACKAGE "passwall2" "xiaorouji/openwrt-passwall2" "main"
UPDATE_PACKAGE "passwall-packages" "xiaorouji/openwrt-passwall-packages" "main"
UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev"
UPDATE_PACKAGE "helloworld" "fw876/helloworld" "master"
#rm -rf $(find ../feeds/ -type d -iname "*helloworld*" -prune)

if [[ $WRT_URL == *"immortalwrt"* ]]; then
	UPDATE_PACKAGE "homeproxy" "immortalwrt/homeproxy" "dev"
fi

#MosDNS(sbwml)
find ../feeds/ | grep Makefile | grep mosdns | xargs rm -f
find ../feeds/ | grep Makefile | grep v2dat | xargs rm -f
find ../feeds/ | grep Makefile | grep v2ray-geodata | xargs rm -f
git clone --depth=1 --single-branch --branch "v5-lua" https://github.com/sbwml/luci-app-mosdns.git
git clone --depth=1 --single-branch https://github.com/sbwml/v2ray-geodata.git
#UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5-lua"
#UPDATE_PACKAGE "v2ray-geodata" "sbwml/v2ray-geodata" "master"

#MosDNS(QiuSimons)
#find ../feeds/ | grep Makefile | grep mosdns | xargs rm -f
#find ../feeds/ | grep Makefile | grep v2ray-geodata | xargs rm -f
#git clone --depth=1 --single-branch https://github.com/QiuSimons/openwrt-mos.git
#UPDATE_PACKAGE "mosdns" "QiuSimons/openwrt-mos" "master"

#SmartDNS
UPDATE_PACKAGE "smartdns" "pymumu/openwrt-smartdns" "master"
UPDATE_PACKAGE "luci-app-smartdns" "pymumu/luci-app-smartdns" "lede"
#git clone --depth=1 --single-branch --branch "lede" https://github.com/pymumu/luci-app-smartdns.git
#git clone --depth=1 --single-branch https://github.com/pymumu/openwrt-smartdns

#Netdata
UPDATE_PACKAGE "luci-app-netdata" "Jason6111/luci-app-netdata" "main"
#git clone --depth=1 --single-branch https://github.com/Jason6111/luci-app-netdata

#Poweroff
UPDATE_PACKAGE "luci-app-poweroff" "esirplayground/luci-app-poweroff" "master"
#git clone --depth=1 --single-branch https://github.com/esirplayground/luci-app-poweroff

#OpenAppFilter
#UPDATE_PACKAGE "OpenAppFilter" "destan19/OpenAppFilter" "master"
#git clone --depth=1 --single-branch https://github.com/destan19/OpenAppFilter

#Fileassistant
UPDATE_PACKAGE "luci-app-fileassistant" "kenzok78/luci-app-fileassistant" "main"
#git clone --depth=1 --single-branch https://github.com/kenzok78/luci-app-fileassistant

#ddns-go
git clone https://github.com/sirpdboy/luci-app-ddns-go.git package/ddns-go

#luci-app-wizard
git clone https://github.com/sirpdboy/luci-app-wizard package/luci-app-wizard

#更新软件包版本
UPDATE_VERSION() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_FILE=$(find ../feeds/packages/*/$PKG_NAME/ -type f -name "Makefile" 2>/dev/null)

	if [ -f "$PKG_FILE" ]; then
		local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" $PKG_FILE)
		local NEW_VER=$(git ls-remote --tags --sort="version:refname" "https://github.com/$PKG_REPO.git" | tail -n 1 | sed "s/.*v//")
		local NEW_HASH=$(curl -sfL "https://codeload.github.com/$PKG_REPO/tar.gz/v$NEW_VER" | sha256sum | cut -b -64)

		if dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" $PKG_FILE
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" $PKG_FILE
			echo "$PKG_NAME ver has been updated!"
		else
			echo "$PKG_NAME ver is already the latest!"
		fi
	else
		echo "$PKG_NAME is not found!"
	fi
}

UPDATE_VERSION "sing-box" "SagerNet/sing-box"
