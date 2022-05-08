#!/usr/bin/env bash
#
# projects-nexus
# Import or update wireguard
#

user_agent="WireGuard-AndroidROMBuild/0.3 ($(uname -a))"
wireguard_url="https://git.zx2c4.com/wireguard-linux-compat/snapshot/wireguard-linux-compat"

cd "$HOME" || exit 1

while read -r distro package version _; do
        if [[ $distro == upstream && $package == linuxcompat ]]; then
                ver="$version"
                break
        fi
done < <(curl -A "${user_agent}" -LSs --connect-timeout 30 https://build.wireguard.com/distros.txt)

if [ ! -f "wireguard-linux-compat-${ver}.zip" ]; then
	wget "${wireguard_url}"-"${ver}".zip
    unzip wireguard-linux-compat-"${ver}".zip -d wireguard
fi

read -p "Provide kernel source folder name: " kdir
if [ ! -d "${kdir}"/net/wireguard ]; then
    mkdir "${kdir}"/net/wireguard
    cp -r wireguard/*/src/* "${kdir}"/net/wireguard
    cd "${kdir}" || exit 1
    git add net/wireguard/*
    git commit -s -m "net: import wireguard-linux-compat ${ver}"
else
    rm -rf "${kdir}"/net/wireguard
    cp -r wireguard/*/src/* "${kdir}"/net/wireguard
    cd "${kdir}" || exit 1
    git add net/wireguard/*
    git commit -s -m "Merge tag 'v${ver}' of ${wireguard_url}"
fi

cd "$HOME" || exit 1 && rm -rf wireguard*
echo "Done."
