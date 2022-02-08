#!/bin/bash

# Meta definition
PKGNAME=wechat-uos
PKGVERS=2.1.2
DEBNAME=com.tencent.weixin_${PKGVERS}_amd64.deb
PKGLINK=https://home-store-packages.uniontech.com/appstore/pool/appstore/c/com.tencent.weixin/${DEBNAME}
WORKDIR=/tmp/${PKGNAME}
DESTDIR=$HOME/software/${PKGNAME}
SHARE_CORE_PATH=${DESTDIR}/share/${PKGNAME}
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
sudo yum install bubblewrap bsdtar

# Download files
wget ${PKGLINK}
wget https://aur.archlinux.org/cgit/aur.git/plain/license.tar.gz?h=wechat-uos -O license.tar.gz

# Processing and install the debian package
bsdtar -xf ${DEBNAME}
bsdtar -xf data.tar.xz
mkdir -p ${SHARE_CORE_PATH}
cp -a ${WORKDIR}/opt/apps/com.tencent.weixin/files/weixin/ ${SHARE_CORE_PATH}/
mkdir -p ${SHARE_ICON_PATH}
cp -a ${WORKDIR}/usr/share/icons/hicolor/ ${SHARE_ICON_PATH}/

# Hacks
sudo mkdir -p /usr/lib/license
sudo touch /etc/lsb-release
sudo touch /etc/os-release
mkdir -p ${SHARE_CORE_PATH}/license/usr/lib/license
tar -xf license.tar.gz
cp -a ${WORKDIR}/license/etc/ ${SHARE_CORE_PATH}/license/
cp -a ${WORKDIR}/license/var/ ${SHARE_CORE_PATH}/license/
cp -a ${WORKDIR}/usr/lib/license/ ${SHARE_CORE_PATH}/license/usr/lib/
cd ${SHARE_CORE_PATH}/license/usr/lib/license/
ln -sf libuosdevicea1.so libuosdevicea.so
cd ${WORKDIR}

# Binary
mkdir -p ${BINARY_PATH}
touch ${BINARY_FILE}
chmod +x ${BINARY_FILE}
echo "#!/bin/bash -e" > ${BINARY_FILE}
echo "bwrap --dev-bind / / \\" >> ${BINARY_FILE}
echo "  --bind ${SHARE_CORE_PATH}/license/etc/os-release /etc/os-release \\" >> ${BINARY_FILE}
echo "  --bind ${SHARE_CORE_PATH}/license/etc/lsb-release /etc/lsb-release \\" >> ${BINARY_FILE}
echo "  --bind ${SHARE_CORE_PATH}/license/usr/lib/license/ /usr/lib/license/ \\" >> ${BINARY_FILE}
echo "  --bind ${SHARE_CORE_PATH}/license/var/ /var/ \\" >> ${BINARY_FILE}
echo "  ${SHARE_CORE_PATH}/weixin/weixin" >> ${BINARY_FILE}

# Desktop entry
mkdir -p ${SHARE_APPS_PATH}
echo "[Desktop Entry]" > ${SHARE_APPS_FILE}
echo "Name=WeChat" >> ${SHARE_APPS_FILE}
echo "Exec=${BINARY_FILE} %U" >> ${SHARE_APPS_FILE}
echo "Icon=weixin" >> ${SHARE_APPS_FILE}
echo "Type=Application" >> ${SHARE_APPS_FILE}
echo "StartupNotify=true" >> ${SHARE_APPS_FILE}
echo "Categories=Application;chat;" >> ${SHARE_APPS_FILE}

# Stow it
cd ${DESTDIR}/../
stow ${PKGNAME}
