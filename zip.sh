#!/bin/bash
cp arch/arm/boot/zImage ../AnyKernel3/
cd ../AnyKernel3
zip -r ../$1 anykernel.sh dt META-INF/ tools/ zImage
