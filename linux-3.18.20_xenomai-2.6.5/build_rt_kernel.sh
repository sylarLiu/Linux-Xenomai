#! /usr/bin/env bash

#===================================================================================
#   Copyright (C) 2018 . All rights reserved.
#   
#   File Name    ： init.sh
#   Author       ： sylar.liu
#   E-mail       ： sylar_liu65@163.com
#   Created Time ： 2018/11/09 14:48:26
#   Description  ： This script is used to build linux-3.18.20 with xenomai-2.6.5
#
#===================================================================================

VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
BLEU="\\033[1;34m"

KERNEL_VERSION="linux-3.18.20"
XENOMAI_VERSION="xenomai-2.6.5"
PROJECT=${KERNEL_VERSION}_${XENOMAI_VERSION}

PROJECT_DIR=`cd $(dirname $0); pwd`
SOURCE_DIR=$PROJECT_DIR/"source"
PACKAGE_DIR=$PROJECT_DIR/"package"
KERNEL_SOURCE_DIR=$SOURCE_DIR/$KERNEL_VERSION
XENOMAI_SOURCE_DIR=$SOURCE_DIR/$XENOMAI_VERSION

KERNEL_PACKAGE="$KERNEL_VERSION.tar.gz"
XENOMAI_PACKAGE="$XENOMAI_VERSION.tar.bz2"
KERNEL_URL="https://www.kernel.org/pub/linux/kernel/v3.x/$KERNEL_PACKAGE"
XENOMAI_URL="http://xenomai.org/downloads/xenomai/stable/$XENOMAI_PACKAGE"
KERNEL_CONFIG="$PROJECT_DIR/config/${KERNEL_VERSION}_${XENOMAI_VERSION}_kernel_config"

if [ ! -d $SOURCE_DIR ]; then
  	echo -e "$BLEU""Can not find souce directory, create it.""$NORMAL"
	mkdir $SOURCE_DIR
	rtval=`echo $?`
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error, create $SOURCE_DIR fail, exit.""$NORMAL"
		exit 1
	fi
fi
cd $SOURCE_DIR

# Prepare linux-3.18.20
if [ ! -d $KERNEL_SOURCE_DIR ]; then
  	if [ ! -f $KERNEL_PACKAGE ]; then
		echo -e "$BLEU""Can not find $KERNEL_PACKAGE, start to download it...""$NORMAL"
		sleep 2

  		wget $KERNEL_URL
		rtval=`echo $?`
		if [ $rtval -ne 0 ]; then
	  		echo -e "$ROUGE""Error, download $KERNEL_PACKAGE from $KERNEL_URL fail, exit.""$NORMAL"
			exit 1
		fi
		echo -e "$VERT""Download $KERNEL_PACKAGE completed.""$NORMAL"
		sleep 2
	fi

	echo -e "$VERT""Unpack $KERNEL_PACKAGE...""$NORMAL"
	sleep 2

	tar xzvf $KERNEL_PACKAGE
	rtval=`echo $?`
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error, unpack $KERNEL_PACKAGE fail, exit.""$NORMAL"
		exit 1
	fi

	echo -e "$VERT""Unpack $KERNEL_PACKAGE completed.""$NORMAL"

	# Modify 768 line of linux-3.18.20/Makefile
	sed -i '768s/^/#/g' $KERNEL_SOURCE_DIR/Makefile
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error, modify line 768 of $KERNEL_SOURCE_DIR/Makefile fail, exit.""$NORMAL"
		exit 1
	fi
	echo -e "$VERT""Modify line 768 of $KERNEL_SOURCE_DIR/Makefile completed.""$NORMAL"
	sleep 2
fi
echo -e "$VERT""Find $KERNEL_SOURCE_DIR""$NORMAL"
sleep 2

# Prepare xenomai-2.6.5
if [ ! -d $XENOMAI_SOURCE_DIR ]; then
	if [ ! -f $XENOMAI_PACKAGE ]; then
 		echo -e "$BLEU""Can not find $XENOMAI_PACKAGE, start to download it ...""$NORMAL"
		sleep 2

		wget $XENOMAI_URL
		rtval=`echo $?`
		if [ $rtval -ne 0 ]; then
	  		echo -e "$ROUGE""Download $XENOMAI_PACKAGE from $XENOMAI_URL fail, exit.""$NORMAL"
			exit 1
		fi
		echo -e "$VERT""Download $XENOMAI_PACKAGE completed.""$NORMAL"
		sleep 2
	fi

	echo -e "$VERT""Unpack $XENOMAI_PACKAGE...""$NORMAL"
	sleep 2

	tar xfvj $XENOMAI_PACKAGE
	rtval=`echo $?`
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error, unpack $XENOMAI_PACKAGE fail, exit.""$NORMAL"
		exit 1
	fi

	echo -e "$VERT""Unpack $XENOMAI_PACKAGE completed.""$NORMAL"

	# Modify 121 line of xenomai-2.6.5/scripts/prepare-kernel.sh
	sed -i '121s/-sf/-f/' $XENOMAI_SOURCE_DIR/scripts/prepare-kernel.sh
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error, modify line 121 of $XENOMAI_SOURCE_DIR fail, exit.""$NORMAL"
		exit 1
	fi
	echo -e "$VERT""Modify line 121 of $XENOMAI_SOURCE_DIR/scripts/prepare-kernel.sh completed.""$NORMAL"
	echo -e "$VERT""Unpack $XENOMAI_PACKAGE completed.""$NORMAL"
	sleep 2
fi
echo -e "$VERT""Find $XENOMAI_SOURCE_DIR""$NORMAL"
sleep 2

# Prepare the tool: kernel-package
echo -e "$VERT""Start to install kernel-package...""$NORMAL"
sleep 2
sudo apt-get update
sudo apt-get install kernel-package -y
sudo apt-get install libncurses5-dev -y

# Patch the kernel
cd $KERNEL_SOURCE_DIR
$XENOMAI_SOURCE_DIR/scripts/prepare-kernel.sh --arch=x86_64 --ipipe=$XENOMAI_SOURCE_DIR/ksrc/arch/x86/patches/ipipe-core-3.18.20-x86-7.patch
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Error, prepare kernel fail, exit.""$NORMAL"
	exit 1
fi

if [ ! -f  $KERNEL_CONFIG]; then
  	echo -e "$ROUGE""Error, can not find kernel config file: $KERNEL_CONFIG""$NORMAL"
	exit 1
fi
cp $KERNEL_CONFIG $KERNEL_SOURCE_DIR/.config
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Error, configure kernel fail, exit.""$NORMAL"
	exit 1
fi

# Now, compile the kernel
CONCURRENCY_LEVEL=$(nproc) make-kpkg --rootcmd fakeroot --initrd kernel_image kernel_headers
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Error, compile kernel fail, exit.""$NORMAL"
	exit 1
fi
echo -e "$VERT""Compile the kernel completed""$NORMAL"
