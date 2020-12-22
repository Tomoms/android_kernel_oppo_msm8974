#!/bin/bash
setenv () {
	export ARCH=arm
	export SUBARCH=arm
	export CROSS_COMPILE=../../lineage-17.1/prebuilts/gcc/linux-x86/arm/arm32-gcc/bin/arm-eabi-
}

checkenv () {
	if [[ $ARCH != "arm" ]] || [[ $SUBARCH != "arm" ]] || [[ $CROSS_COMPILE != "../../lineage-17.1/prebuilts/gcc/linux-x86/arm/arm32-gcc/bin/arm-eabi-" ]]; then
		echo "Environment variables are unset!"
		return 1
	fi
	echo "All good!"
}

fullclean () {
	setenv
	if ! checkenv; then
		echo "Aborting!"
		return 1
	fi
	echo "Performing a full clean..."
	make mrproper
}

clean () {
	setenv
	if ! checkenv; then
		echo "Aborting!"
		return 1
	fi
	echo "Cleaning..."
	make clean
}

mkcfg () {
	setenv
	if ! checkenv; then
		echo "Aborting!"
		return 1
	fi
	if [ -f ".config" ]; then
		echo ".config exists, running make oldconfig"
		make oldconfig
	else
		echo ".config not found"
		make lineageos_bacon_defconfig
	fi
}

editcfg () {
	setenv
	if ! checkenv; then
		echo "Aborting!"
		return 1
	fi
	if [ -f ".config" ]; then
		echo ".config exists"
		patch -p1 < 0001-temp-to-build-on-SUSE.patch
		make nconfig
		git checkout scripts/kconfig/nconf.c
	else
		echo ".config not found, run mkcfg first!"
		return 1
	fi
}

savecfg () {
	setenv
	if ! checkenv; then
		echo "Aborting!"
		return 1
	fi
	make savedefconfig
	mv defconfig arch/arm/configs/lineageos_bacon_defconfig
}

build () {
	setenv
	if ! checkenv; then
		echo "Aborting!"
		return 1
	fi
	if [ -z "$1" ]; then
		echo "No number of jobs has been passed"
		return 1
	fi
	echo "Running make..."
	make --version
	make -j$1
	../dtbToolCM -2 -o ../AnyKernel3/dt -s 2048 -p scripts/dtc/ arch/arm/boot/
}

mkzip () {
	if [ -z "$1" ]; then
		echo "Name of zip file is missing!"
		return 1
	fi
	cp arch/arm/boot/zImage ../AnyKernel3/
	(cd ../AnyKernel3 && zip -r ../$1 *)
}
