#!/bin/bash
reset

export bversion="v10.2";

DELAY()
{
	sleep 1;
}

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
export ARCH=arm;
export SUBARCH=arm;
export KERNELDIR=`readlink -f .`;
export DEFCONFIG=kernel_defconfig;
export CROSS_COMPILE=$KERNELDIR/android/toolchain/bin/arm-eabi-;
export NRCPUS=`grep 'processor' /proc/cpuinfo | wc -l`;

echo "${bldcya}***** Starting Breakfast $bversion...${txtrst}";
DELAY;

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

CLEAN()
{
	echo "${bldcya}***** Cleaning up source...${txtrst}";
	DELAY;
	make mrproper;
	make clean;

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

CLEAN_JUNK()
{
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

DEFCONFIG()
{
	if [ ! -f $KERNELDIR/arch/arm/configs/$DEFCONFIG ]; then
		echo "${bldcya}***** Creating defconfig...${txtrst}";
		DELAY;
		make hammerhead_defconfig;
		mv .config arch/arm/configs/$DEFCONFIG;
		CLEAN;
		echo "${bldgrn}***** Created!${txtrst}";
		DELAY;
	else
		echo "${bldgrn}***** Defconfig loaded!${txtrst}";
		DELAY;
	fi
}

BUILD()
{
	make $DEFCONFIG;

	echo "${bldcya}***** Building -> Kernel${txtrst}";
	DELAY;

	make -j$NRCPUS zImage-dtb;

	if [ -e $KERNELDIR/arch/arm/boot/zImage-dtb ]; then
		mv arch/arm/boot/zImage-dtb $KERNELDIR/android/ready-kernel/core/

		cd android/ready-kernel/

		rm -rf Kernel.zip
		zip -r Kernel.zip .

		cd ../../
		CLEAN;

		echo "${bldgrn}***** Kernel was successfully built!${txtrst}";
		DELAY;
	else
		echo "${bldred}***** ERROR: Kernel STUCK in BUILD!${txtrst}";
		DELAY;
	fi
}

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
