#!/sbin/sh

mkdir /tmp/ramdisk
cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/
cd /tmp/ramdisk/
gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | cpio -i

found=$(find /tmp/ramdisk/init.rc -type f | xargs grep -oh "userinit");
if [ ! $found ]; then
        echo "" >> /tmp/ramdisk/init.rc
        echo "service userinit /system/xbin/busybox run-parts /system/etc/init.d" >> /tmp/ramdisk/init.rc
        echo "    class late_start" >> /tmp/ramdisk/init.rc
        echo "    user root" >> /tmp/ramdisk/init.rc
        echo "    group root" >> /tmp/ramdisk/init.rc
        echo "    oneshot" >> /tmp/ramdisk/init.rc
fi

rm /tmp/boot.img-ramdisk.gz
rm /tmp/ramdisk/boot.img-ramdisk.gz
rm /tmp/ramdisk/fstab.hammerhead
rm /tmp/ramdisk/init.hammerhead.rc
cp /tmp/fstab.hammerhead /tmp/ramdisk/
cp /tmp/init.hammerhead.rc /tmp/ramdisk/
chmod 640 /tmp/ramdisk/fstab.hammerhead
chmod 750 /tmp/ramdisk/init.hammerhead.rc
find . | cpio -o -H newc | gzip > /tmp/boot.img-ramdisk.gz
rm -r /tmp/ramdisk
