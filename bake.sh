#!/bin/bash
reset

# You should install 'parallel' to use this script!
if [ ! -e /usr/bin/parallel ]; then
	sudo apt-get install parallel;
fi

# Script version
export bversion="v12";

# Global delay function
DELAY()
{
	sleep 1;
}

# Colors support
export txtbld=$(tput bold)
export txtrst=$(tput sgr0)
export red=$(tput setaf 1)
export grn=$(tput setaf 2)
export blu=$(tput setaf 4)
export cya=$(tput setaf 6)
export bldred=${txtbld}$(tput setaf 1)
export bldgrn=${txtbld}$(tput setaf 2)
export bldblu=${txtbld}$(tput setaf 4)
export bldcya=${txtbld}$(tput setaf 6)

# Build configuration
export ARCH=arm;
export SUBARCH=arm;
export KERNELDIR=`readlink -f .`;
export DEFCONFIG=kernel_defconfig;
export CROSS_COMPILE=$KERNELDIR/android/toolchain/bin/arm-eabi-;
export NRCPUS=`grep 'processor' /proc/cpuinfo | wc -l`;

echo "${bldcya}***** Starting Breakfast $bversion...${txtrst}";
DELAY;

# Check for GCC
CHECK()
{
	echo "${bldcya}***** Checking for GCC...${txtrst}";
	DELAY;
	if [ ! -f ${CROSS_COMPILE}gcc ]; then
		echo "${bldred}***** ERROR: Cannot find GCC!${txtrst}";
		DELAY;
		exit 1;
	fi
	echo "${bldgrn}***** Checked!${txtrst}";
	DELAY;
}

# Clean source before the building
CLEAN()
{
	echo "${bldcya}***** Cleaning up source...${txtrst}";
	DELAY;
	# Main cleaning
	make mrproper;
	make clean;

	# Clean files that were left
	rm -rf $KERNELDIR/tmp;
	rm -rf $KERNELDIR/arch/arm/boot/*.dtb;
	rm -rf $KERNELDIR/arch/arm/boot/*.cmd;
	rm -rf $KERNELDIR/arch/arm/mach-msm/smd_rpc_sym.c;
	rm -rf $KERNELDIR/arch/arm/crypto/aesbs-core.S;
	rm -rf $KERNELDIR/include/generated;
	rm -rf $KERNELDIR/arch/*/include/generated;
	rm -rf $KERNELDIR/android/ready-kernel/core/zImage-dtb;

	echo "${bldgrn}***** Cleaned!${txtrst}";
	DELAY;
}

# Remove junk files from the patches
CLEAN_JUNK()
{
	# Clean junk from patches and git
	find . -type f \( -iname \*.rej \
			-o -iname \*.orig \
			-o -iname \*.bkp \
			-o -iname \*.ko \
			-o -iname \*.c.BACKUP.[0-9]*.c \
			-o -iname \*.c.BASE.[0-9]*.c \
			-o -iname \*.c.LOCAL.[0-9]*.c \
			-o -iname \*.c.REMOTE.[0-9]*.c \
			-o -iname \*.org \) \
				| parallel rm -fv {};
}

# Check for defconfig. If no, create it
DEFCONFIG()
{
	if [ ! -f $KERNELDIR/arch/arm/configs/$DEFCONFIG ]; then
		echo "${bldcya}***** Creating defconfig...${txtrst}";
		DELAY;
		# Create <device_name>_defconfig
		make hammerhead_defconfig;
		mv .config $KERNELDIR/arch/arm/configs/$DEFCONFIG;
		CLEAN;
		echo "${bldgrn}***** Created!${txtrst}";
		DELAY;
	else
		echo "${bldgrn}***** Defconfig loaded!${txtrst}";
		DELAY;
	fi
}

# Start building
BUILD()
{
	make $DEFCONFIG;

	echo "${bldcya}***** Building -> Kernel${txtrst}";
	DELAY;

	make -j$NRCPUS zImage-dtb;

	if [ -e $KERNELDIR/arch/arm/boot/zImage-dtb ]; then
		mv $KERNELDIR/arch/arm/boot/zImage-dtb $KERNELDIR/android/ready-kernel/core/

		# Trap into ready-kernel tree
		cd $KERNELDIR/android/ready-kernel/

		# Create a flashable zip
		rm -rf Kernel.zip
		zip -r Kernel.zip .

		# Go back to the root path
		cd ../../
		CLEAN;

		echo "${bldgrn}***** Kernel was successfully built!${txtrst}";
		DELAY;
	else
		echo "${bldred}***** ERROR: Kernel STUCK in BUILD!${txtrst}";
		DELAY;
	fi
}

# Initialization
INIT()
{
	CLEAN_JUNK;
	if [ -e $KERNELDIR/scripts/basic/fixdep ]; then
		CLEAN;
	fi
	CHECK;
	DEFCONFIG;
	DELAY;
	echo "${bldgrn}***** Build starts at 3${txtrst}";
	DELAY;
	echo "${bldgrn}***** Build starts at 2${txtrst}";
	DELAY;
	echo "${bldgrn}***** Build starts at 1${txtrst}";
	DELAY;
	BUILD;
}
INIT;
