#!/res/busybox sh

export PATH=/res/asset:$PATH
export ext4=1

mount -t ext4 -o ro,noatime,nodiratime,data=ordered,barrier=1,nodiscard /dev/block/platform/msm_sdcc.1/by-name/system /system
mount -t f2fs -o ro,noatime,nodiratime,background_gc=off,discard /dev/block/platform/msm_sdcc.1/by-name/system /system

if [ ! -f /system/priv-app/SystemUI/SystemUI.apk ] ; then
	export ext4=0
	umount -f /system
	mount -t ext4 -o noatime,nodiratime,nosuid,nodev,barrier=1,data=ordered,nodiscard,nomblk_io_submit,errors=panic /dev/block/platform/msm_sdcc.1/by-name/userdata /arter97/data
	mount -t f2fs -o noatime,nodiratime,background_gc=on,discard,nosuid,nodev /dev/block/platform/msm_sdcc.1/by-name/userdata /arter97/data
	chmod 755 /arter97/data/arter97_secondrom/system
	chmod 771 /arter97/data/arter97_secondrom/data
	chmod 771 /arter97/data/arter97_secondrom/cache
	mount --bind /arter97/data/arter97_secondrom/system /system
	mount --bind /arter97/data/arter97_secondrom/data /data
	mount --bind /arter97/data/arter97_secondrom/cache /cache
	mount --bind -o remount,suid,dev /system
	if [ -f /arter97/data/media/0/.arter97/shared ]; then
		rm -rf /arter97/data/arter97_secondrom/data/media/0/.arter97
		cp -rp /arter97/data/arter97_secondrom/data/media/* /arter97/data/media/
		rm -rf /data/media/*
		mount --bind /arter97/data/media /data/media
	fi
	CUR_PATH=$PATH
	export PATH=/sbin:/system/sbin:/system/bin:/system/xbin
	export LD_LIBRARY_PATH=/vendor/lib:/system/lib
	run-parts /arter97/data/arter97_secondrom/init.d
	export PATH=$CUR_PATH
else
	rm -rf /arter97
	mount -t ext4 -o noatime,nodiratime,nosuid,nodev,barrier=1,data=ordered,nodiscard,nomblk_io_submit,errors=panic /dev/block/platform/msm_sdcc.1/by-name/userdata /data || export ext4=0
	mount -t f2fs -o noatime,nodiratime,background_gc=on,discard,nosuid,nodev /dev/block/platform/msm_sdcc.1/by-name/userdata /data
	mount -t ext4 -o noatime,nodiratime,nosuid,nodev,barrier=1,data=ordered,nodiscard,nomblk_io_submit,errors=panic /dev/block/platform/msm_sdcc.1/by-name/cache /cache
	mount -t f2fs -o noatime,nodiratime,background_gc=on,discard,nosuid,nodev /dev/block/platform/msm_sdcc.1/by-name/cache /cache
fi

if [[ $ext4 == "1" ]]; then
	sed -i -e 's/#EXT4/\/dev\/block\/platform\/msm_sdcc.1\/by-name\/userdata     \/data           ext4    noatime,nosuid,nodev,barrier=1,data=ordered,nodiscard,nomblk_io_submit,errors=panic    wait,check,encryptable=\/dev\/block\/platform\/msm_sdcc.1\/by-name\/metadata/g' /fstab.flo
	umount -f /data
fi

touch /dev/block/mounted
