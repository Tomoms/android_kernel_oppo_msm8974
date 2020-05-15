#!/bin/bash
setenv () {
	export ARCH=arm
	export SUBARCH=arm
	export CROSS_COMPILE="/run/media/tfonda/HDD/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-"
	export LD_LIBRARY_PATH="/run/media/tfonda/HDD/android/twisted-clang/lib"
}

checkenv () {
	if [[ $ARCH != "arm" ]] || [[ $SUBARCH != "arm" ]] || [[ $CROSS_COMPILE != "/run/media/tfonda/HDD/gcc-arm-9.2-2019.12-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-" ]] || [[ $LD_LIBRARY_PATH != "/run/media/tfonda/HDD/android/twisted-clang/lib" ]]; then
		echo "Environment variables are unset!"
		return 1
	fi
	echo "All good!"
}

fullclean () {
	#setenv
	if ! checkenv; then
		echo "Aborting!"
		return 1
	fi
	echo "Performing a full clean..."
	make mrproper CC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang HOSTCC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang
}

clean () {
	#setenv
	if ! checkenv; then
		echo "Aborting!"
		return 1
	fi
	echo "Cleaning..."
	make clean CC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang HOSTCC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang
}

mkcfg () {
	#setenv
	if ! checkenv; then
		echo "Aborting!"
		return 1
	fi
	if [ -f ".config" ]; then
		echo ".config exists, running make oldconfig"
		make oldconfig CC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang HOSTCC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang
	else
		echo ".config not found"
		make lineageos_bacon_defconfig CC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang HOSTCC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang
	fi
}

editcfg () {
	#setenv
	if ! checkenv; then
		echo "Aborting!"
		return 1
	fi
	if [ -f ".config" ]; then
		echo ".config exists"
		make nconfig CC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang HOSTCC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang
	else
		echo ".config not found, run mkcfg first!"
		return 1
	fi
}

savecfg () {
	#setenv
	if ! checkenv; then
		echo "Aborting!"
		return 1
	fi
	make savedefconfig CC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang HOSTCC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang
	mv defconfig arch/arm/configs/lineageos_bacon_defconfig
}

build () {
	#setenv
	if ! checkenv; then
		echo "Aborting!"
		return 1
	fi
	if [ -z "$1" ]; then
		echo "No number of jobs has been passed"
		return 1
	fi
	echo "Running make..."
	make -j$1 CC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang HOSTCC=/run/media/tfonda/HDD/android/twisted-clang/bin/clang
	../dtbToolCM -2 -o ../AnyKernel3/dt -s 2048 -p scripts/dtc/ arch/arm/boot/
}

mkzip () {
	if [ -z "$1" ]; then
		echo "Name of zip file is missing!"
		return 1
	fi
	cp arch/arm/boot/zImage ../AnyKernel3/
	(cd ../AnyKernel3 && zip -r ../$1 anykernel.sh dt META-INF/ tools/ zImage)
}
