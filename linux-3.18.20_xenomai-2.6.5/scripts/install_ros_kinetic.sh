#! /usr/bin/env bash

#================================================================
#   Copyright (C) 2018 . All rights reserved.
#   
#   File Name    ： install_ros_kinetic.sh
#   Author       ： sylar.liu
#   E-mail       ： sylar_liu65@163.com
#   Created Time ： 2018/11/12 15:54:42
#   Description  ： This script is used to install ROS Kinetic.
#					It is based on http://wiki.ros.org/kinetic/Installation/Ubuntu
#
#================================================================

VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
BLEU="\\033[1;34m"

user=`whoami`
if [ $user == "root" ]; then
  	echo -e "$ROUGE""Error, execute the script without sudo.""$NORMAL"
	exit 1
fi

echo -e "$BLEU""Attention: ROS Kinetic ONLY supports Wily(Ubuntu 15.10), \
Xenial(Ubuntu 16.04) and Jessie(Debian 8) for debian packages.""$NORMAL"
sleep 3

# Configure your Ubuntu repositories
echo -e "$VERT""Start to configure Ubuntu repositores...""$NORMAL"
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Configure Ubuntu repositories fail, exit.""$NORMAL"
	exit 1
fi
echo -e "$VERT""Configure Ubuntu repositories completed.""$NORMAL"
sleep 2

# Set up your keys
echo -e "$VERT""Start to setup keys...""$NORMAL"
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Set up keys fail, exit.""$NORMAL"
	exit 1
fi
echo -e "$VERT""Set up keys completed.""$NORMAL"
sleep 2

echo -e "$VERT""Update apt sources...""$NORMAL"
sudo apt-get update
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Update apt sources fail, exit.""$NORMAL"
	exit 1
fi
echo -e "$VERT""Update apt sources completed.""$NORMAL"
sleep 2

# Desktop-Full Install
echo -e "$VERT""Start to install ros-kinetic-desktop-full...""$NORMAL"
sudo apt-get install ros-kinetic-desktop-full -y
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Install ros-kinetic-desktop-full fail, exit""$NORMAL"
	exit 1
fi
echo -e "$VERT""Install ros-kinetic-desktop-full completed.""$NORMAL"
sleep 3

# Initialize rosdep
echo -e "$VERT""Initialize rosdep...""$NORMAL"
if [ -f "/etc/ros/rosdep/sources.list.d/20-default.list" ]; then
  	sudo rm "/etc/ros/rosdep/sources.list.d/20-default.list"
fi
sudo rosdep init
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Initialize rosdep fail, eixt.""$NORMAL"
	exit 1
fi
echo -e "$VERT""Initialize rosdep completed.""$NORMAL"

echo -e "$VERT""Update rosdep...""$NORMAL"
rosdep update
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Update rosdep fail, exit.""$NORMAL"
	exit 1
fi
echo -e "$VERT""Update rosdep completed.""$NORMAL"
sleep 2

# Environment setup
echo -e "$VERT""Set up ROS environment...""$NORMAL"
result="`cat ~/.bashrc | grep "source /opt/ros/kinetic/setup.sh"`"
if [ -z $result ]; then
	echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
	rtval=$?
	if [ $rtval -ne 0 ]; then
	  	echo -e "$ROUGE""Set up ROS environment fail, exit.""$NORMAL"
		exit 1
	fi
fi
source ~/.bashrc
echo -e "$VERT""Set up ROS environment completed.""$NORMAL"
sleep 2

# Dependencies for building packages
echo -e "$VERT""Install dependencies for build packages...""$NORMAL"
sudo apt-get install python-rosinstall python-rosinstall-generator python-wstool build-essential -y
rtval=$?
if [ $rtval -ne 0 ]; then
  	echo -e "$ROUGE""Install dependencies for build packages fail, exit.""$NORMAL"
	exit 1
fi
echo -e "$VERT""Install dependencies for build packages completed.""$NORMAL"
