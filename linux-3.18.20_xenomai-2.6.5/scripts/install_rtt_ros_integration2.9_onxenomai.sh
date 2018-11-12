#! /usr/bin/env bash

#====================================================================
#   Copyright (C) 2018 . All rights reserved.
#   
#   File Name    ： rtt_ros_integration2.9_onxenomai.sh
#   Author       ： sylar.liu
#   E-mail       ： sylar_liu65@163.com
#   Created Time ： 2018/11/12 21:27:48
#   Description  ： This script is used to build RTT ROS integration
#
#====================================================================

OROCOS_INSTALL_PREFIX="/opt/orocos-2.9"
RTT_ROS_INTEGRATION_INSTALL_PREFIX="/opt/rtt_ros-2.9"

user=`whoami`
if [ $user != "root" ]; then
    echo "You have to execute the script with sudo."
    exit 1
fi

# Compile for Xenomai
export OROCOS_TARGET=xenomai

mkdir -p $RTT_ROS_INTEGRATION_INSTALL_PREFIX/src
cd $RTT_ROS_INTEGRATION_INSTALL_PREFIX/src

# Get all the packages
wstool init
wstool merge https://github.com/kuka-isir/rtt_lwr/raw/rtt_lwr-2.0/lwr_utils/config/rtt_ros_integration-2.9.rosinstall
wstool update -j$(nproc)

cd $RTT_ROS_INTEGRATION_INSTALL_PREFIX

# Install dependencies
source $OROCOS_INSTALL_PREFIX/install/setup.bash
rosdep install --from-paths $RTT_ROS_INTEGRATION_INSTALL_PREFIX/src --ignore-src --rosdistro kinetic -y -r

catkin config --init --install --extend $OROCOS_INSTALL_PREFIX/install --cmake-args -DCMAKE_BUILD_TYPE=Release -DENABLE_MQ=ON -DENABLE_CORBA=ON -DCORBA_IMPLEMENTATION=OMNIORB

catkin build
