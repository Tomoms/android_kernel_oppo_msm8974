#!/bin/bash
export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=/run/media/tfonda/HDD/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-

if [ -f ".config" ]; then
    echo ".config exist"
    make oldconfig
else 
    echo ".config does not exist"
    make lineageos_bacon_defconfig
fi

echo ""
read -r -p "Do you want to edit the kernel configuration? [y/n] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]; then
    echo "Launching nconfig..."
    make nconfig
else
    echo "Ok, building with the current configuration"
fi

make -j1
../dtbToolCM -2 -o ../AnyKernel3/dt -s 2048 -p scripts/dtc/ arch/arm/boot/
