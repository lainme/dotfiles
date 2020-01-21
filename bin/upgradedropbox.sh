#!/bin/bash

cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -

ver=`cat $HOME/.dropbox-dist/VERSION`
dir=$HOME/.dropbox-dist/dropbox-lnx.x86_64-$ver

patchelf --set-interpreter $HOME/software/glibc-2.27/lib/ld-2.27.so  $dir/dropbox
patchelf --set-rpath $HOME/software/glibc-2.27/lib $dir/dropbox

ln -s /lib64/libgcc_s.so.1 $dir
ln -s /usr/lib64/libstdc++.so.6 $dir
ln -s /lib64/libz.so.1 $dir
ln -s /lib64/libgthread-2.0.so.0 $dir
ln -s /lib64/libglib-2.0.so.0 $dir
