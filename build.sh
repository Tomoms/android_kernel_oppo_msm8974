#!/bin/bash
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=/run/media/tfonda/HDD/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-

make lineageos_bacon_defconfig

make -j1
../dtbToolCM -2 -o ../AnyKernel3/dt -s 2048 -p scripts/dtc/ arch/arm/boot/

cp arch/arm/boot/zImage ../AnyKernel3/
cd ../AnyKernel3
zip -r ../$1 anykernel.sh dt META-INF/ tools/ zImage
