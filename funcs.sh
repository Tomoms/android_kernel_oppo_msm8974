#!/bin/bash
setenv () {
	export ARCH=arm
	export SUBARCH=arm
	export CROSS_COMPILE=/mnt/nvme/bacon/lineage-18.1/prebuilts/gcc/linux-x86/arm/arm32-gcc/bin/arm-eabi-
}

checkenv () {
	if [[ $ARCH != "arm" ]] || [[ $SUBARCH != "arm" ]] || [[ $CROSS_COMPILE != "/mnt/nvme/bacon/lineage-18.1/prebuilts/gcc/linux-x86/arm/arm32-gcc/bin/arm-eabi-" ]]; then
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
		if [[ "${1}" == "twrp" ]]; then
			echo "Using twrp's defconfig"
			make twrp_bacon_defconfig
		else
			echo "Using lineageos's defconfig"
			make lineageos_bacon_defconfig
		fi
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
		make nconfig
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
	if [[ "${1}" == "twrp" ]]; then
		mv defconfig arch/arm/configs/twrp_bacon_defconfig
	else
		mv defconfig arch/arm/configs/lineageos_bacon_defconfig
	fi
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
	make -j$1
	../dtbToolCM -2 -o ../AnyKernel3/dt -s 2048 -p scripts/dtc/ arch/arm/boot/
}

mkzip () {
	cp arch/arm/boot/zImage ../AnyKernel3/
	(cd ../AnyKernel3 && zip -r ../kernel_Tom_`date +%Y%m%d`.zip *)
	printf "Sideload zip? [Y/n]"
	read answer
	if [[ $answer != "n" ]]; then
		adb sideload ../kernel_Tom_`date +%Y%m%d`.zip
	fi
}
