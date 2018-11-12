#! /usr/bin/env bash

#================================================================
#   Copyright (C) 2018 . All rights reserved.
#   
#   File Name    ： install_RTnet.sh
#   Author       ： sylar.liu
#   E-mail       ： sylar_liu65@163.com
#   Created Time ： 2018/11/11 22:22:13
#   Description  ： This script is used to install RTnet
#
#================================================================

VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
BLEU="\\033[1;34m"

RTNET_SOURCE_DIR="RTnet"
RTNET_PACKAGE="../package/RTnet.tar.gz"
RTNET_INSTALL_PREIFX="/usr/local/rtnet"

CURRENT_USER=`basename ~`
if [ -z $CURRENT_USER ]; then
  	echo -e "$ROUGE""Can not get current user name, exit.""$NORMAL"
	exit 1
fi
XENOMAI_RC="/home/$CURRENT_USER/.xenomai_rc"
if [ ! -f $XENOMAI_RC ]; then
  	echo -e "$ROUGE""Can not find xenomai environment, exit.""$NORMAL"
	exit 1
fi
echo -e "$VERT""Find xenomai env in $XENOMAI_RC""$NORMAL"

echo -e "$VERT""Start to install RTnet""$NORMAL"
sleep 2

if [ ! -d "${RTNET_SOURCE_DIR}" ]
then
    if [ ! -f "${RTNET_PACKAGE}" ]
	then
	    echo -e "$ROUGE""Can not find RTnet, exit.""$NORMAL"
		exit 1
	fi

	tar -xzvf ${RTNET_PACKAGE}
	rtval=$?
	if [ $rtval -ne 0 ]; then 
	  	echo -e "$ROUGE""Unpack $RTNET_PACKAGE fail, exit.""$NORMAL"
		exit 1
	fi
fi

# import xenomai environment
source $XENOMAI_RC

cd ${RTNET_SOURCE_DIR}
sudo make clean
./configure --enable-dependency-tracking \
  --enable-eepro100 --enable-r8169 \
  --enable-e1000 --enable-e1000-new --enable-e1000e \
  --enable-tcp --enable-tcp-error-injection \
  --enable-rtcfg-dbg --enable-rtcap \
  --enable-examples
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Configure RTnet fail, exit.""$NORMAL"
	exit 1
fi

make
rtvel=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Compile RTnet fail, exit.""$NORMAL"
	exit 1
fi

if [ -d $RTNET_INSTALL_PREIFX ]; then 
  	echo -e "$BLEU""$RTNET_INSTALL_PREIFX already exists, delete it.""$NORMAL"
	sleep 3
	sudo rm -rf $RTNET_INSTALL_PREIFX
fi

sudo make install
rtvel=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Install RTnet fail, exit.""$NORMAL"
	exit 1
fi

# to do : check if the contents exist already
#chmod u+w "/etc/sudoers"
#echo '
#%xenomai ALL=(root) NOPASSWD:/sbin/insmod
#%xenomai ALL=(root) NOPASSWD:/sbin/rmmod
#%xenomai ALL=(root) NOPASSWD:/sbin/modprobe
#%xenomai ALL=(root) NOPASSWD:/bin/echo
#%xenomai ALL=(root) NOPASSWD:/bin/mknod
#%xenomai ALL=(root) NOPASSWD:/usr/bin/service
#%xenomai ALL=(root) NOPASSWD:/usr/sbin/service
#%xenomai ALL=(root) NOPASSWD:/usr/local/rtnet/sbin/rtcfg
#%xenomai ALL=(root) NOPASSWD:/usr/local/rtnet/sbin/rtifconfig
#%xenomai ALL=(root) NOPASSWD:/usr/local/rtnet/sbin/rtiwconfig
#%xenomai ALL=(root) NOPASSWD:/usr/local/rtnet/sbin/rtnet
#%xenomai ALL=(root) NOPASSWD:/usr/local/rtnet/sbin/rtping
#%xenomai ALL=(root) NOPASSWD:/usr/local/rtnet/sbin/rtroute
#%xenomai ALL=(root) NOPASSWD:/usr/local/rtnet/sbin/tdmacfg
#' >> "/etc/sudoers"
#chmod a-w "/etc/sudoers"

echo -e "$VERT""RTNet install completed"
echo -e "reboot...""$NORMAL"
sleep 5
reboot
