#!/bin/bash
export KERNELDIR=`readlink -f .`
if [ "${1}" = "aosp" ] ; then
	export RAMFS_SOURCE=`readlink -f $KERNELDIR/ramdisk_aosp`
	export BOOT_IMG=aosp.img
	export ARG=$(echo "$@" | sed s/aosp//g)
	echo "Building with AOSP ramdisk ..."
else
	export RAMFS_SOURCE=`readlink -f $KERNELDIR/ramdisk_cm`
	export BOOT_IMG=cm.img
	export ARG=$(echo "$@" | sed s/cm//g)
	echo "Building with CyanogenMod ramdisk ..."
fi
export USE_SEC_FIPS_MODE=true

echo "kerneldir = $KERNELDIR"
echo "ramfs_source = $RAMFS_SOURCE"

RAMFS_TMP="/tmp/arter97-flo-ramdisk"

echo "ramfs_tmp = $RAMFS_TMP"
cd $KERNELDIR

if [ "${1}" = "skip" ] || [ "${2}" = "skip" ] ; then
	echo "Skipping Compilation"
else
	echo "Compiling kernel"
	cp defconfig .config
	make $ARG || exit 1
fi

echo "Building new ramdisk"
#remove previous ramfs files
rm -rf '$RAMFS_TMP'*
rm -rf $RAMFS_TMP
rm -rf $RAMFS_TMP.cpio
#copy ramfs files to tmp directory
cp -ax $RAMFS_SOURCE $RAMFS_TMP
cd $RAMFS_TMP

find . -name '*.sh' -exec chmod 755 {} \;

$KERNELDIR/ramdisk_fix_permissions.sh 2>/dev/null

#clear git repositories in ramfs
find . -name .git -exec rm -rf {} \;
find . -name EMPTY_DIRECTORY -exec rm -rf {} \;
cd $KERNELDIR
rm -rf $RAMFS_TMP/tmp/*

cd $RAMFS_TMP
find . | fakeroot cpio -H newc -o | lzop -9 > $RAMFS_TMP.cpio.lzo
ls -lh $RAMFS_TMP.cpio.lzo
cd $KERNELDIR

echo "Making new boot image"
gcc -w -s -pipe -O2 -Itools/libmincrypt -o tools/mkbootimg/mkbootimg tools/libmincrypt/*.c tools/mkbootimg/mkbootimg.c
tools/mkbootimg/mkbootimg --kernel $KERNELDIR/arch/arm/boot/zImage --ramdisk $RAMFS_TMP.cpio.lzo --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=flo user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3 enforcing=0' --base 0x80200000 --pagesize 2048 --ramdisk_offset 0x02000000 --tags_offset 0x00000100 --second_offset 0x00f00000 -o $KERNELDIR/$BOOT_IMG
if echo "$@" | grep -q "CC=\$(CROSS_COMPILE)gcc" ; then
	dd if=/dev/zero bs=$((16777216-$(stat -c %s $BOOT_IMG))) count=1 >> $BOOT_IMG
fi

echo "done"
ls -al $BOOT_IMG
echo ""
