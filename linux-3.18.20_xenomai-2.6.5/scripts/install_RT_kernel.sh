#! /usr/bin/env bash

VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
BLEU="\\033[1;34m"

user_name=`basename ~`
if [ -z $user_name ]; then
  	echo -e "$ROUGE""Get current user name fail, exit.""$NORMAL"
	exit 1
fi
echo -e "$VERT""user: $user_name""$NORMAL"
sleep 3

# install the Real-Time kernel
HEADER="../package/linux-headers-3.18.20-xenomai-2.6.5_3.18.20-xenomai-2.6.5-10.00.Custom_amd64.deb"
IMAGE="../package/linux-image-3.18.20-xenomai-2.6.5_3.18.20-xenomai-2.6.5-10.00.Custom_amd64.deb"

if [ ! -f $HEADER ]; then
  	echo -e "$ROUGE""Error, can not find $HEADER, exit.""$NORMAL"
	exit 1
fi

if [ ! -f $IMAGE ]; then
  	echo -e "$ROUGE""Error, can not find $IMAGE, exit.""$NORMAL"
	exit 1
fi

echo -e "$VERT""Start to install the real-time kernel...""$NORMAL"
sleep 3
sudo dpkg -i $HEADER $IMAGE
rtvel=$?
if [ $rtvel -ne 0 ]; then
  	echo -e "$ROUGE""Install the real-time kernel fail, exit...""$NORMAL"
	exit 1
fi
echo -e "$VERT""Install real-time kernel completed.""$NORMAL"
echo -e "$VERT""Start to configure...""$NORMAL"
sleep 3

# Allow non-root users
group_list=`cat /etc/group`
group_id="60000"
group_name="xenomai"
is_exist="false"
for var in $group_list; do
  	name=`echo $var | cut -d : -f 1`
	id=`echo $var | cut -d : -f 3`
  	if [ $name == $group_name ]; then
	  	echo -e "$BLEU""$group_name is exist""$NORMAL"
		group_id=$id
  		is_exist="true"
		break
	fi
done

if [ $is_exist == "false" ]; then
	sudo addgroup $group_name --gid ${group_id}
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Add group: $group_name $group_id fail, exit.""$NORMAL"
		exit 1
	fi
fi

sudo addgroup root $group_name
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Add root to $group_name fail, exit.""$NORMAL"
	exit 1
fi

sudo echo -e "$VERT""Add $user_name to group $group_name""$NORMAL"
sudo usermod -a -G $group_name $user_name
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Add $user_name to group $group_name fail, exit.""$NORMAL"
	exit 1
fi

# Configure GRUB
echo -e "$VERT""Configure GRUB""$NORMAL"
echo "# If you change this file, run \'update-grub\' afterwards to update
# /boot/grub/grub.cfg.
# For full documentation of the options in this file, see:
#   info -f grub -n \'Simple configuration\'

GRUB_DEFAULT=\"Advanced options for GNU/Linux>GNU/Linux, with Linux 3.18.20-xenomai-2.6.5\"
#GRUB_HIDDEN_TIMEOUT=0
#GRUB_HIDDEN_TIMEOUT_QUIET=true
GRUB_TIMEOUT=5
#GRUB_DISTRIBUTOR=\`lsb_release -i -s 2> /dev/null || echo Debian\`
GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash xeno_nucleus.${group_name}_gid=${group_id}\"
GRUB_CMDLINE_LINUX=\"\"

# Uncomment to enable BadRAM filtering, modify to suit your needs
# This works with Linux (no patch required) and with any kernel that obtains
# the memory map information from GRUB (GNU Mach, kernel of FreeBSD ...)
#GRUB_BADRAM=\"0x01234567,0xfefefefe,0x89abcdef,0xefefefef\"

# Uncomment to disable graphical terminal (grub-pc only)
#GRUB_TERMINAL=console

# The resolution used on graphical terminal
# note that you can use only modes which your graphic card supports via VBE
# you can see them in real GRUB with the command \'vbeinfo\'
#GRUB_GFXMODE=640x480

# Uncomment if you don\'t want GRUB to pass \"root=UUID=xxx\" parameter to Linux
#GRUB_DISABLE_LINUX_UUID=true

# Uncomment to disable generation of recovery mode menu entries
#GRUB_DISABLE_RECOVERY=\"true\"

# Uncomment to get a beep at grub start
#GRUB_INIT_TUNE=\"480 440 1\"
" > "/etc/default/grub"
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Configure grub fail, exit.""$NORMAL"
	exit 1
fi

sudo update-grub
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Update grub fail, exit.""$NORMAL"
	exit 1
fi

echo -e "$VERT""Configure completed, reboot""$NORMAL"
sleep 5
reboot
