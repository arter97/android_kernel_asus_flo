#!/sbin/sh
# 
# /system/addon.d/97-kernel.sh
# During a ROM upgrade, this script prevents kernel writings and backs up stock graphics libraries,
# /system is formatted and reinstalled, then the file is restored.
#

rm /dev/block/mmcblk0p14

. /tmp/backuptool.functions

list_files() {
cat <<EOF
etc/wifi/WCNSS_qcom_cfg.ini
etc/wifi/WCNSS_qcom_wlan_nv_deb.bin
etc/wifi/WCNSS_qcom_wlan_nv_flo.bin
lib/hw/gralloc.default.so
lib/hw/gralloc.msm8960.so
lib/hw/hwcomposer.msm8960.so
lib/hw/memtrack.msm8960.so
lib/libexternal.so
lib/libmemalloc.so
lib/libmemtrack.so
lib/liboverlay.so
lib/libqdutils.so
lib/libqservice.so
vendor/firmware/wlan/prima/WCNSS_cfg.dat
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/"$FILE"
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/"$FILE" "$R"
    done
    rm /system/lib/hw/power.flo.so
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    # Stub
  ;;
  post-restore)
    # Stub
  ;;
esac
