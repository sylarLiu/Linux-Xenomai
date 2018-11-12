#! /usr/bin/env bash

#==============================================================================
#   Copyright (C) 2018 . All rights reserved.
#   
#   File Name    ： install_orocostoolchain2.9_onxenomai.sh
#   Author       ： sylar.liu
#   E-mail       ： sylar_liu65@163.com
#   Created Time ： 2018/11/12 21:06:29
#   Description  ： This script is used to build orocos-toolchain on xenomai
#
#==============================================================================

OROCOS_INSTALL_PREFIX="/opt/orocos-2.9"
ROS_INSTALL_PREFIX="/opt/ros/kinetic"
ROS_DISTRO="kinetic"

user=`whoami`
if [ $user != "root" ]; then
    echo -e "You have to execute the script with sudo."
    exit 1
fi

# import Xenomai environment
source ~/.xenomai_rc

# Compile for Xenomai
export OROCOS_TARGET=xenomai

mkdir -p $OROCOS_INSTALL_PREFIX/src
cd $OROCOS_INSTALL_PREFIX/src

# Get all the packages
wstool init
wstool merge https://raw.githubusercontent.com/kuka-isir/rtt_lwr/rtt_lwr-2.0/lwr_utils/config/orocos_toolchain-2.9.rosinstall
wstool update -j$(nproc)

# Get the latest updates (OPTIONAL)
cd orocos_toolchain
git submodule foreach git checkout toolchain-2.9
git submodule foreach git pull

cd $OROCOS_INSTALL_PREFIX

# Install dependencies
source $ROS_INSTALL_PREFIX/setup.bash
rosdep install --from-paths $OROCOS_INSTALL_PREFIX/src --ignore-src --rosdistro $ROS_DISTRO -y -r
catkin config --init --install --extend $ROS_INSTALL_PREFIX --cmake-args -DCMAKE_BUILD_TYPE=Release -DENABLE_MQ=ON -DENABLE_CORBA=ON -DCORBA_IMPLEMENTATION=OMNIORB
catkin build
