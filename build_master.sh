#!/bin/bash
if [ ! "${1}" = "skip" ] ; then
	./build_clean.sh
	./build_kernel.sh aosp CC='$(CROSS_COMPILE)gcc' "$@"
	./build_kernel.sh cm skip CC='$(CROSS_COMPILE)gcc'
	./build_clean.sh noimg
	./build_recovery.sh CC='$(CROSS_COMPILE)gcc' "$@"
fi

if [ -e aosp.img ] ; then
	rm arter97-kernel-aosp-"$(cat version)".zip 2>/dev/null
	cp aosp.img kernelzip/boot.img
	cd kernelzip/
	7z a -mx9 arter97-kernel-aosp-"$(cat ../version)"-tmp.zip *
	zipalign -v 4 arter97-kernel-aosp-"$(cat ../version)"-tmp.zip ../arter97-kernel-aosp-"$(cat ../version)".zip
	rm arter97-kernel-aosp-"$(cat ../version)"-tmp.zip
	cd ..
	ls -al arter97-kernel-aosp-"$(cat version)".zip
fi

if [ -e cm.img ] ; then
	rm arter97-kernel-cm-"$(cat version)".zip 2>/dev/null
	cp cm.img kernelzip/boot.img
	cd kernelzip/
	7z a -mx9 arter97-kernel-cm-"$(cat ../version)"-tmp.zip *
	zipalign -v 4 arter97-kernel-cm-"$(cat ../version)"-tmp.zip ../arter97-kernel-cm-"$(cat ../version)".zip
	rm arter97-kernel-cm-"$(cat ../version)"-tmp.zip
	cd ..
	ls -al arter97-kernel-cm-"$(cat version)".zip
fi

if [ -e recovery.img ] ; then
	rm arter97-recovery-"$(cat version)"-philz_touch_"$(cat version_recovery | awk '{print $1}')".zip 2>/dev/null
	cp kernelzip/META-INF/com/google/android/update-binary recoveryzip/META-INF/com/google/android/update-binary
	cp recovery.img recoveryzip/
	cd recoveryzip/
	sed -i -e s/PHILZ_VERSION/$(cat ../version_recovery | awk '{print $1}')/g -e s/CWM_VERSION/$(cat ../version_recovery | awk '{print $2 }')/g META-INF/com/google/android/updater-script
	7z a -mx9 arter97-recovery-"$(cat ../version)"-philz_touch_"$(cat ../version_recovery | awk '{print $1}')"-tmp.zip *
	zipalign -v 4 arter97-recovery-"$(cat ../version)"-philz_touch_"$(cat ../version_recovery | awk '{print $1}')"-tmp.zip ../arter97-recovery-"$(cat ../version)"-philz_touch_"$(cat ../version_recovery | awk '{print $1}')".zip
	rm arter97-recovery-"$(cat ../version)"-philz_touch_"$(cat ../version_recovery | awk '{print $1}')"-tmp.zip
	sed -i -e s/$(cat ../version_recovery | awk '{print $1}')/PHILZ_VERSION/g -e s/$(cat ../version_recovery | awk '{print $2 }')/CWM_VERSION/g META-INF/com/google/android/updater-script
	cd ..
	ls -al arter97-recovery-"$(cat version)"-philz_touch_"$(cat version_recovery | awk '{print $1}')".zip
	fakeroot tar -H ustar -c recovery.img > arter97-recovery-"$(cat version)"-philz_touch_"$(cat version_recovery | awk '{print $1}')".tar
	rm recovery/recovery.img recoveryzip/META-INF/com/google/android/update-binary
fi
