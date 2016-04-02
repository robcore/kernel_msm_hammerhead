#!/sbin/sh

dd if=/tmp/newboot.img of=/dev/block/platform/msm_sdcc.1/by-name/boot || exit 1
exit 0
