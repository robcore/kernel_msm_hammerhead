#!/tmp/busybox sh

BB=/tmp/busybox

systemfs=$(eval $($BB blkid /dev/block/platform/msm_sdcc.1/by-name/system | $BB awk ' { print $3 } '); $BB echo $TYPE);
datafs=$(eval $($BB blkid /dev/block/platform/msm_sdcc.1/by-name/userdata | $BB awk ' { print $3 } '); $BB echo $TYPE);
DATA_MOUNT=$($BB mount | $BB grep /data | $BB wc -l);

$BB mount -t $systemfs /dev/block/platform/msm_sdcc.1/by-name/system /system;

if [ "$DATA_MOUNT" -eq "0" ]; then
	$BB mount -t $datafs /dev/block/platform/msm_sdcc.1/by-name/userdata /data;
fi;

