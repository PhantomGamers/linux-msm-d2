#!/bin/bash
date=`date +%h-%d-%y`
filename="d2vzw_3.4-caf_kernel-$date.zip"

make ARCH=arm CROSS_COMPILE=gcc/arm-linux-androideabi-4.7/bin/arm-linux-androideabi- mrproper -j6
make ARCH=arm CROSS_COMPILE=gcc/arm-linux-androideabi-4.7/bin/arm-linux-androideabi- cyanogen_d2vzw_defconfig -j6
make ARCH=arm CROSS_COMPILE=gcc/arm-linux-androideabi-4.7/bin/arm-linux-androideabi- -j6
find drivers -name "*.ko" | xargs gcc/arm-linux-androideabi-4.7/bin/arm-linux-androideabi-strip --strip-unneeded
mkdir -p tmp/out/system/lib/modules
if [ -d zip ]; then rm -r zip; fi
mkdir zip
find drivers -name "*.ko" | xargs -i cp {} tmp/out/system/lib/modules/
cd cm.ramdisk
chmod 750 init*
chmod 644 default* uevent*
chmod 755 sbin
find . | cpio -o -H newc | gzip > ../tmp/out/ramdisk.img
cd ../
tmp/tools/mkbootimg --kernel arch/arm/boot/zImage --ramdisk tmp/out/ramdisk.img --base 0x80200000 --ramdiskaddr 0x81500000 --pagesize 2048 --cmdline 'androidboot.hardware=qcom user_debug=31 zcache' -o tmp/out/boot.img
cp -r tmp/tools/META-INF tmp/out/
cd tmp/out
rm ramdisk.img
zip -r $filename *
mv $filename ../../zip
cd ../../
rm -r tmp/out
