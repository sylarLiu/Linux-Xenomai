#!/bin/bash -
#===============================================================================
#
#          FILE: install_xenomai_library.sh
#
#         USAGE: ./install_xenomai_library.sh
#
#   DESCRIPTION: Installing Xenomai User space libraries
#
#        AUTHOR: sylar.liu
#       CREATED: 2018年11月02日 14时52分12秒
#===============================================================================

VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
BLEU="\\033[1;34m"

KERNEL_RELEASE="3.18.20-xenomai-2.6.5"
kernel_version="3.18.20"
XENOMAI_SOURCE_DIR="xenomai-2.6.5"
XENOMAI_PACKAGE="../package/xenomai-2.6.5.tar.bz2"
XENOMAI_INSTALL_PREFIX="/usr/xenomai"

echo -e "$VERT""Start to install xenomai-2.6.5 user space library.""$NORMAL"
sleep 3

if [ `uname -r` != $KERNEL_RELEASE ]; then
  	echo -e "$ROUGE""Error, You have to install Linux $KERNEL_RELEASE \
before install Xenomai user space library.""$NORMAL"
	exit 1
fi

if [ ! -d $XENOMAI_SOURCE_DIR ]; then
  	if [ ! -f $XENOMAI_PACKAGE ]; then
	  	echo -e "$ROUGE""Can not find $XENOMAI_PACKAGE, exit.""$NORMAL"
		exit 1
	fi
	
	tar -xjvf $XENOMAI_PACKAGE
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Error: unpack $XENOMAI_PACKAGE fail, exit.""$NORMAL"
		exit 1
	fi
fi

cd $XENOMAI_SOURCE_DIR
sudo make clean
./configure 
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Configure xenomai fail, exit.""$NORMAL"
	exit 1
fi

make -j $(nproc)
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Compile xenomai fail, exit""$NORMAL"
	exit 1
fi

if [ -d $XENOMAI_INSTALL_PREFIX ]; then
	echo -e "$BLEU""$XENOMAI_INSTALL_PREFIX already exists, delete it.""$NORMAL"
	sleep 3
	sudo rm -rf $XENOMAI_INSTALL_PREFIX
fi

sudo make install
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Install xenomai fail, exit.""$NORMAL"
	exit 1
fi

# Update your bashrc
echo -e "$VERT""Update bashrc""$NORMAL"
sleep 3
sudo echo '
### Xenomai
export XENOMAI_ROOT_DIR=/usr/xenomai
export XENOMAI_PATH=/usr/xenomai
export PATH=$PATH:$XENOMAI_PATH/bin
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$XENOMAI_PATH/lib/pkgconfig
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$XENOMAI_PATH/lib
export OROCOS_TARGET=xenomai
' > ~/.xenomai_rc
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Update ~/.xenomairc fail, exit.""$NORMAL"
	exit 1
fi

if [ -z "`grep 'source ~/.xenomai_rc' ~/.bashrc`" ]; then
	sudo echo 'source ~/.xenomai_rc
	' >> ~/.bashrc
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Update bashrc fail, exit.""$NORMAL"
		exit 1
	fi
fi
echo -e "$VERT""Update bashrc completed.""$NORMAL"
sleep 2
source ~/.bashrc

echo -e "$VERT""Install xenomai user space library completed.""$NORMAL"
echo -e "$VERT""reboot...""$NORMAL"
sleep 5
reboot
