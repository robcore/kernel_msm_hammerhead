#!/sbin/sh

if [ -e /system/bin/thermal-engine-hh ]; then
	rm -rf /system/bin/thermal-engine-hh;
fi
if [ -e /system/etc/thermal-engine-8974.conf ]; then
	rm -rf /system/etc/thermal-engine-8974.conf;
fi

dd if=/tmp/newboot.img of=/dev/block/platform/msm_sdcc.1/by-name/boot || exit 1
exit 0
