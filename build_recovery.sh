#!/bin/bash
export KERNELDIR=`readlink -f .`
export RAMFS_SOURCE=`readlink -f $KERNELDIR/recovery`
export USE_SEC_FIPS_MODE=true

echo "kerneldir = $KERNELDIR"
echo "ramfs_source = $RAMFS_SOURCE"

RAMFS_TMP="/tmp/arter97-flo-recovery"

echo "ramfs_tmp = $RAMFS_TMP"
cd $KERNELDIR

if [ "${1}" = "skip" ] ; then
	echo "Skipping Compilation"
else
	echo "Compiling kernel"
	cp defconfig .config

        scripts/configcleaner "
CONFIG_KALLSYMS
CONFIG_IOSCHED_TEST
CONFIG_IOSCHED_DEADLINE
CONFIG_IOSCHED_FIFO
CONFIG_IOSCHED_CFQ
CONFIG_IOSCHED_VR
CONFIG_IOSCHED_ZEN
CONFIG_IOSCHED_BFQ
CONFIG_IOSCHED_SIO
CONFIG_DEFAULT_DEADLINE
CONFIG_DEFAULT_CFQ
CONFIG_DEFAULT_NOOP
CONFIG_DEFAULT_VR
CONFIG_DEFAULT_FIFO
CONFIG_DEFAULT_ZEN
CONFIG_CPU_FREQ_GOV_POWERSAVE
CONFIG_CPU_FREQ_GOV_USERSPACE
CONFIG_CPU_FREQ_GOV_ONDEMAND
CONFIG_CPU_FREQ_GOV_INTERACTIVE
CONFIG_CPU_FREQ_GOV_POWERSAVE
CONFIG_CPU_FREQ_GOV_USERSPACE
CONFIG_CPU_FREQ_GOV_ONDEMAND
CONFIG_CPU_FREQ_GOV_INTERACTIVE
CONFIG_TCP_CONG_ADVANCED
CONFIG_TCP_CONG_BIC
CONFIG_TCP_CONG_ADVANCED
CONFIG_TCP_CONG_WESTWOOD
CONFIG_TCP_CONG_HTCP
CONFIG_TCP_CONG_HSTCP
CONFIG_TCP_CONG_HYBLA
CONFIG_TCP_CONG_VEGAS
CONFIG_TCP_CONG_SCALABLE
CONFIG_TCP_CONG_LP
CONFIG_TCP_CONG_VENO
CONFIG_TCP_CONG_YEAH
CONFIG_TCP_CONG_ILLINOIS
CONFIG_DEFAULT_BIC
CONFIG_DEFAULT_CUBIC
CONFIG_DEFAULT_HTCP
CONFIG_DEFAULT_HYBLA
CONFIG_DEFAULT_VEGAS
CONFIG_DEFAULT_VENO
CONFIG_DEFAULT_WESTWOOD
CONFIG_DEFAULT_RENO
CONFIG_DEFAULT_TCP_CONG
CONFIG_HIDRAW
CONFIG_FS_POSIX_ACL
CONFIG_NETWORK_FILESYSTEMS
CONFIG_NFS_FS
CONFIG_NFS_V3
CONFIG_NFS_V3_ACL
CONFIG_NFS_V4
CONFIG_NFS_V4_1
CONFIG_ROOT_NFS
CONFIG_NFS_USE_LEGACY_DNS
CONFIG_NFS_USE_KERNEL_DNS
CONFIG_NFSD
CONFIG_LOCKD
CONFIG_LOCKD_V4
CONFIG_NFS_ACL_SUPPORT
CONFIG_NFS_COMMON
CONFIG_SUNRPC
CONFIG_SUNRPC_GSS
CONFIG_SUNRPC_DEBUG
CONFIG_CEPH_FS
CONFIG_CIFS
CONFIG_CIFS_STATS
CONFIG_CIFS_WEAK_PW_HASH
CONFIG_CIFS_UPCALL
CONFIG_CIFS_XATTR
CONFIG_CIFS_DEBUG2
CONFIG_CIFS_DFS_UPCALL
CONFIG_NCP_FS
CONFIG_CODA_FS
CONFIG_AFS_FS
CONFIG_NETWORK_FILESYSTEMS
"
	echo "
# CONFIG_KALLSYMS is not set
# CONFIG_IOSCHED_TEST is not set
# CONFIG_IOSCHED_DEADLINE is not set
# CONFIG_IOSCHED_FIFO is not set
# CONFIG_IOSCHED_CFQ is not set
# CONFIG_IOSCHED_VR is not set
# CONFIG_IOSCHED_ZEN is not set
# CONFIG_IOSCHED_BFQ is not set
# CONFIG_IOSCHED_SIO is not set
# CONFIG_DEFAULT_DEADLINE is not set
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
# CONFIG_DEFAULT_VR is not set
# CONFIG_DEFAULT_FIFO is not set
# CONFIG_DEFAULT_ZEN is not set
# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_GOV_INTERACTIVE is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_HIDRAW is not set
# CONFIG_FS_POSIX_ACL is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
" >> .config
	sed -i -e 's/-Ofast/-Os/g' Makefile
	make "$@" || exit 1
	git checkout Makefile
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
tools/mkbootimg/mkbootimg --kernel $KERNELDIR/arch/arm/boot/zImage --ramdisk $RAMFS_TMP.cpio.lzo --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=flo user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3 vmalloc=340M enforcing=0' --base 0x80200000 --pagesize 2048 --ramdisk_offset 0x02000000 --tags_offset 0x00000100 --second_offset 0x00f00000 -o $KERNELDIR/recovery.img
if echo "$@" | grep -q "CC=\$(CROSS_COMPILE)gcc" ; then
	dd if=/dev/zero bs=$((10485760-$(stat -c %s recovery.img))) count=1 >> recovery.img
fi

echo "done"
ls -al recovery.img
echo ""
