#! /usr/bin/env bash

#==========================================================================================
#   Copyright (C) 2018 . All rights reserved.
#   
#   File Name    ： build_install_package.sh
#   Author       ： sylar.liu
#   E-mail       ： sylar_liu65@163.com
#   Created Time ： 2018/11/09 14:48:26
#   Description  ： The script is used to build linux-3.18.20_xenomai-2.6.5_install.tar.gz
#
#==========================================================================================

VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
BLEU="\\033[1;34m"

KERNEL_VERSION="linux-3.18.20"
XENOMAI_VERSION="xenomai-2.6.5"
PROJECT=${KERNEL_VERSION}_${XENOMAI_VERSION}

XENOMAI_PACKAGE="$XENOMAI_VERSION.tar.bz2"
XENOMAI_URL="http://xenomai.org/downloads/xenomai/stable/$XENOMAI_PACKAGE"
RTNET_PACKAGE="RTnet.tar.gz"

PROJECT_DIR=`cd $(dirname $0); pwd`
SOURCE_DIR=$PROJECT_DIR/"source"
PACKAGE_DIR=$PROJECT_DIR/"package"

if [ ! -d $PACKAGE_DIR ]; then
  	echo -e "$BLEU""Can not find package directory, create it.""$NORMAL"
	mkdir $PACKAGE_DIR
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error, create $PACKAGE_DIR fail, exit.""$NORMAL"
		exit 1
	fi
fi

if [ ! -d $SOURCE_DIR ]; then
  	echo -e "$BLEU""Can not find souce directory, create it.""$NORMAL"
	mkdir $SOURCE_DIR
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error, create $SOURCE_DIR fail, exit.""$NORMAL"
		exit 1
	fi
fi
cd $SOURCE_DIR

# Copy xenomai package to package directory
if [ ! -f $XENOMAI_PACKAGE ]; then
  	echo -e "$BLEU""Can not find $XENOMAI_PACKAGE, try to download it...""$NORMAL"

	wget $XENOMAI_URL
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error, download $XENOMAI_PACKAGE from $XENOMAI_URL fail, exit.""$NORMAL"
		exit 1
	fi
fi
echo -e "$VERT""Find $XENOMAI_PACKAGE""$NORMAL"
sleep 1
cp $XENOMAI_PACKAGE $PACKAGE_DIR
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Error, copy $XENOMAI_PACKAGE to $PACKAGE_DIR fail, exit.""$NORMAL"
	exit 1
fi

# Copy RTnet package to package directory
if [ ! -f $RTNET_PACKAGE ]; then
  	echo -e "$BLEU""Can not find $RTNET_PACKAGE, try to download it...""$NORMAL"
	git clone -b develop git@github.com:sylarLiu/RTnet.git
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error, download RTnet fail, exit.""$NORMAL"
		exit 1
	fi
	tar czvf $RTNET_PACKAGE RTnet
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error, pack RTnet fail, exit""$NORMAL"
		exit 1
	fi
fi
echo -e "$VERT""Find $RTNET_PACKAGE""$NORMAL"
sleep 1
cp $RTNET_PACKAGE $PACKAGE_DIR
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Copy $RTNET_PACKAGE to $PACKAGE_DIR fail, exit.""$NORMAL"
	exit 1
fi

# Copy linux header and image to package directory
LINUX_HEADER=`find $SOURCE_DIR -name "linux-header*3.18.20*2.6.5*.deb"`
LINUX_IMAGE=`find $SOURCE_DIR -name "linux-image*3.18.20*2.6.5*.deb"`
if [ -z $LINUX_HEADER ]; then
  	echo -e "$ROUGE""Error, can not find linux header package, exit.""$NORMAL"
	exit 1
else
  	echo -e "$VERT""Find $LINUX_HEADER""$NORMAL"
	sleep 1
  	cp $LINUX_HEADER $PACKAGE_DIR
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error, copy $LINUX_HEADER to $PACKAGE_DIR fail, exit.""$NORMAL"
		exit 1
	fi
fi

if [ -z $LINUX_IMAGE ]; then
  	echo -e "$ROUGE""Error, can not find linux image, exit.""$NORMAL"
	exit 1
else
	echo -e "$VERT""Find $LINUX_IMAGE""$NORMAL"
	sleep 1
  	cp $LINUX_IMAGE $PACKAGE_DIR
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error, copy $LINUX_IMAGE to $PACKAGE_DIR fail, exit.""$NORMAL"
		exit 1
	fi
fi

# Pack
cd $PROJECT_DIR
cd ..
tar czvf $PROJECT.tar.gz $PROJECT/scripts $PROJECT/package
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Error, create the install package fail, exit.""$NORMAL"
	exit 1
fi
echo -e "$VERT""Create $PROJECT.tar.gz completed.""$NORMAL"
