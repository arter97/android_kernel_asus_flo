#!/res/busybox sh

exec 2>&1 > /dev/kmsg

export PATH=/res/asset:$PATH

if [ -e /arter97 ] ; then
	fstrim -v /arter97/data
else
	fstrim -v /system
	fstrim -v /cache
	fstrim -v /persist
	fstrim -v /data
fi

sync
