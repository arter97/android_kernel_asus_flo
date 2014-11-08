#!/bin/bash
if [ "${1}" = "skip" ] ; then
	device=$(echo $(\ls *.img) | sed s/.img//g)
	if [ "$device" = "recovery" ] ; then
		rm arter97-recovery-i9506-"$(cat version_recovery | awk '{print $1}')".zip 2>/dev/null
		cp recovery.img recoveryzip/recovery.img
		cd recoveryzip/
		cp ../kernelzip/META-INF/com/google/android/update-binary META-INF/com/google/android/update-binary
		sed -i -e s/PHILZ_VERSION/$(cat ../version_recovery | awk '{print $1}')/g -e s/CWM_VERSION/$(cat ../version_recovery | awk '{print $2 }')/g META-INF/com/google/android/updater-script
		7z a -mx9 arter97-recovery-i9506-"$(cat ../version_recovery | awk '{print $1}')"-tmp.zip *
		zipalign -v 4 arter97-recovery-i9506-"$(cat ../version_recovery | awk '{print $1}')"-tmp.zip ../arter97-recovery-i9506-"$(cat ../version_recovery | awk '{print $1}')".zip
		sed -i -e s/$(cat ../version_recovery | awk '{print $1}')/PHILZ_VERSION/g -e s/$(cat ../version_recovery | awk '{print $2 }')/CWM_VERSION/g META-INF/com/google/android/updater-script
		rm arter97-recovery-i9506-"$(cat ../version_recovery | awk '{print $1}')"-tmp.zip
		cd ..
		rm recoveryzip/META-INF/com/google/android/update-binary
		ls -al arter97-recovery-i9506-"$(cat version_recovery | awk '{print $1}')".zip
	else
		rm arter97-kernel-$device-"$(cat version)".zip 2>/dev/null
		cp *.img kernelzip/boot.img
		cd kernelzip/
		7z a -mx9 arter97-kernel-$device-"$(cat ../version)"-tmp.zip *
		zipalign -v 4 arter97-kernel-$device-"$(cat ../version)"-tmp.zip ../arter97-kernel-$device-"$(cat ../version)".zip
		rm arter97-kernel-$device-"$(cat ../version)"-tmp.zip
		cd ..
		ls -al arter97-kernel-$device-"$(cat version)".zip
	fi
	exit 0
fi

./build_clean.sh
./build_kernel_e330s.sh CC='$(CROSS_COMPILE)gcc'

device=$(echo $(\ls e330*.img) | sed s/.img//g)
rm arter97-kernel-$device-"$(cat version)".zip 2>/dev/null
cp e330*.img kernelzip/boot.img
cd kernelzip/
7z a -mx9 arter97-kernel-$device-"$(cat ../version)"-tmp.zip *
zipalign -v 4 arter97-kernel-$device-"$(cat ../version)"-tmp.zip ../arter97-kernel-$device-"$(cat ../version)".zip
rm arter97-kernel-$device-"$(cat ../version)"-tmp.zip
cd ..
ls -al arter97-kernel-$device-"$(cat version)".zip

./build_clean.sh nozip
./build_kernel_e330k.sh CC='$(CROSS_COMPILE)gcc'

device=$(echo $(\ls e330*.img) | sed s/.img//g)
rm arter97-kernel-$device-"$(cat version)".zip 2>/dev/null
cp e330*.img kernelzip/boot.img
cd kernelzip/
7z a -mx9 arter97-kernel-$device-"$(cat ../version)"-tmp.zip *
zipalign -v 4 arter97-kernel-$device-"$(cat ../version)"-tmp.zip ../arter97-kernel-$device-"$(cat ../version)".zip
rm arter97-kernel-$device-"$(cat ../version)"-tmp.zip
cd ..
ls -al arter97-kernel-$device-"$(cat version)".zip

./build_clean.sh nozip
./build_kernel_i9506.sh CC='$(CROSS_COMPILE)gcc'

rm arter97-kernel-i9506-"$(cat version)".zip 2>/dev/null
cp i9506.img kernelzip/boot.img
cd kernelzip/
7z a -mx9 arter97-kernel-i9506-"$(cat ../version)"-tmp.zip *
zipalign -v 4 arter97-kernel-i9506-"$(cat ../version)"-tmp.zip ../arter97-kernel-i9506-"$(cat ../version)".zip
rm arter97-kernel-i9506-"$(cat ../version)"-tmp.zip
cd ..
ls -al arter97-kernel*.zip

./build_clean.sh nozip
./build_recovery.sh CC='$(CROSS_COMPILE)gcc'

rm arter97-recovery-i9506-"$(cat version_recovery | awk '{print $1}')".zip 2>/dev/null
cp recovery.img recoveryzip/recovery.img
cd recoveryzip/
cp ../kernelzip/META-INF/com/google/android/update-binary META-INF/com/google/android/update-binary
sed -i -e s/PHILZ_VERSION/$(cat ../version_recovery | awk '{print $1}')/g -e s/CWM_VERSION/$(cat ../version_recovery | awk '{print $2 }')/g META-INF/com/google/android/updater-script
7z a -mx9 arter97-recovery-i9506-"$(cat ../version_recovery | awk '{print $1}')"-tmp.zip *
zipalign -v 4 arter97-recovery-i9506-"$(cat ../version_recovery | awk '{print $1}')"-tmp.zip ../arter97-recovery-i9506-"$(cat ../version_recovery | awk '{print $1}')".zip
sed -i -e s/$(cat ../version_recovery | awk '{print $1}')/PHILZ_VERSION/g -e s/$(cat ../version_recovery | awk '{print $2 }')/CWM_VERSION/g META-INF/com/google/android/updater-script
rm arter97-recovery-i9506-"$(cat ../version_recovery | awk '{print $1}')"-tmp.zip
cd ..
rm recoveryzip/META-INF/com/google/android/update-binary
ls -al arter97-recovery-i9506-"$(cat version_recovery | awk '{print $1}')".zip
