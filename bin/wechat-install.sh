#!/bin/bash

# Meta definition
PKGNAME=wechat-uos
PKGVERS=2.0.0-2
DEBNAME=com.qq.weixin_${PKGVERS}_amd64.deb
PKGLINK=https://cdn-package-store6.deepin.com/appstore/pool/appstore/c/com.qq.weixin/${DEBNAME}
WORKDIR=/tmp/${PKGNAME}
DESTDIR=$HOME/software/${PKGNAME}
SHARE_CORE_PATH=${DESTDIR}/share/${PKGNAME}
SHARE_CRAP_PATH=${SHARE_CORE_PATH}/crap
SHARE_ICON_PATH=${DESTDIR}/share/icons
SHARE_APPS_PATH=${DESTDIR}/share/applications
SHARE_APPS_FILE=${DESTDIR}/share/applications/${PKGNAME}.desktop
BINARY_PATH=${DESTDIR}/bin
BINARY_FILE=${BINARY_PATH}/${PKGNAME}

# Working directory
sudo rm -rf ${WORKDIR}
mkdir -p ${WORKDIR}
cd ${WORKDIR}

# Install depends
sudo yum install bubblewrap bsdtar ImageMagick

# Download files
wget ${PKGLINK}
wget https://aur.archlinux.org/cgit/aur.git/plain/uos-lsb?h=wechat-uos -O uos-lsb
wget https://aur.archlinux.org/cgit/aur.git/plain/uos-lsblk?h=wechat-uos -O uos-lsblk
wget https://aur.archlinux.org/cgit/aur.git/plain/uos-release?h=wechat-uos -O uos-release

# Processing and install the debian package
bsdtar -xf ${DEBNAME}
bsdtar -xf data.tar.xz
for s in 128 64 48 16; do
    NEWSIZE="${s}x${s}"
    convert -geometry ${NEWSIZE} \
        ${WORKDIR}/opt/apps/com.qq.weixin/entries/icons/hicolor/256x256/apps/wechat.png \
        ${WORKDIR}/opt/apps/com.qq.weixin/entries/icons/hicolor/${NEWSIZE}/apps/wechat.png
done
mkdir -p ${SHARE_CORE_PATH}
cp -a ${WORKDIR}/opt/apps/com.qq.weixin/files/* ${SHARE_CORE_PATH}/
mkdir -p ${SHARE_ICON_PATH}
cp -a ${WORKDIR}/opt/apps/com.qq.weixin/entries/icons/* ${SHARE_ICON_PATH}/

# Hacks
sudo mkdir -p /usr/lib/license
sudo install -Dm644 ${WORKDIR}/usr/lib/license/libuosdevicea.so -t /usr/lib/license/
sudo touch /etc/lsb-release
mkdir -p ${SHARE_CRAP_PATH}
install -Dm644 uos-lsb -t ${SHARE_CRAP_PATH}/
install -Dm644 uos-release -t ${SHARE_CRAP_PATH}/
install -Dm755 uos-lsblk -t ${SHARE_CRAP_PATH}/

# Binary
mkdir -p ${BINARY_PATH}
touch ${BINARY_FILE}
chmod +x ${BINARY_FILE}
echo "#!/bin/bash -e" > ${BINARY_FILE}
echo "bwrap --dev-bind / / \\" >> ${BINARY_FILE}
echo "  --bind ${SHARE_CRAP_PATH}/uos-release /etc/os-release \\" >> ${BINARY_FILE}
echo "  --bind ${SHARE_CRAP_PATH}/uos-lsb /etc/lsb-release \\" >> ${BINARY_FILE}
echo "  --bind ${SHARE_CRAP_PATH}/uos-lsblk /usr/bin/lsblk \\" >> ${BINARY_FILE}
echo "  ${SHARE_CORE_PATH}/wechat" >> ${BINARY_FILE}

# Desktop entry
mkdir -p ${SHARE_APPS_PATH}
echo "[Desktop Entry]" > ${SHARE_APPS_FILE}
echo "Name=WeChat" >> ${SHARE_APPS_FILE}
echo "Exec=${BINARY_FILE} %U" >> ${SHARE_APPS_FILE}
echo "Icon=wechat" >> ${SHARE_APPS_FILE}
echo "Type=Application" >> ${SHARE_APPS_FILE}
echo "StartupNotify=true" >> ${SHARE_APPS_FILE}
echo "Categories=Application;chat;" >> ${SHARE_APPS_FILE}

# Stow it
cd ${DESTDIR}/../
stow ${PKGNAME}
