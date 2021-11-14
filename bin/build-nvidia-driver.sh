#!/bin/bash

cd /lib/modules/

for dir in *; do
    if [ -f $dir/modules.drm ]; then
        if [ ! -f $dir/kernel/drivers/video/nvidia.ko ]; then
            sudo bash /home/lainme/Downloads/installer/NVIDIA-Linux-x86_64-470.74.run --kernel-name="$dir" -K
        fi
    fi
done
