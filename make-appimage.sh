#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q waydroid | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/512x512/apps/waydroid.png
export DESKTOP=/usr/share/applications/Waydroid.desktop
export DEPLOY_SYS_PYTHON=1

# Deploy dependencies
mkdir -p ./AppDir/bin
cp -r /usr/lib/waydroid/* ./AppDir/bin
ln -s waydroid.py ./AppDir/bin/waydroid
quick-sharun \
	./AppDir/bin/*            \
	/usr/bin/nft              \
	/usr/lib/libnftables.so*  \
	/usr/bin/dnsmasq          \
	/usr/bin/pgrep            \
	/usr/bin/12to11           \
	/usr/bin/init.lxc         \
	/usr/bin/lxc-*            \
	/usr/lib/lxc              \
	/etc/lxc                  \
	/usr/lib/libgtk-3.so*     \
	/usr/lib/libgbinder.so*   \
	/usr/lib/libglibutil.so*  \
	/usr/share/dbus-1         \
	/usr/bin/zenity
find ./AppDir/share/dbus-1 -type f ! -name '*waydro*' -delete

# add polkit policy file
dst=./AppDir/share/polkit-1/actions
mkdir -p "$dst"
cp -v /usr/share/polkit-1/actions/id.waydro.Container.policy "$dst"

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
