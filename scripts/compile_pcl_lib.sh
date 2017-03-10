#!/bin/bash

cd ~

sudo apt-get update
sudo apt-get -y install git

git clone https://github.com/PointCloudLibrary/pcl.git pcl-trunk
ln -s pcl-trunk pcl

sudo apt-get -y install g++
sudo apt-get -y install cmake cmake-gui
sudo apt-get -y install doxygen  
sudo apt-get -y install mpi-default-dev openmpi-bin openmpi-common  
sudo apt-get -y install libflann1 libflann-dev
sudo apt-get -y install libeigen3-dev
sudo apt-get -y install libboost-all-dev
sudo apt-get -y install libvtk5.8-qt4 libvtk5.8 libvtk5-dev
sudo apt-get -y install libqhull*
sudo apt-get -y install libusb-dev
sudo apt-get -y install libgtest-dev
sudo apt-get -y install git-core freeglut3-dev pkg-config
sudo apt-get -y install build-essential libxmu-dev libxi-dev 
sudo apt-get -y install libusb-1.0-0-dev graphviz mono-complete
sudo apt-get -y install qt-sdk openjdk-7-jdk openjdk-7-jre

sudo apt-get -y install phonon-backend-gstreamer
sudo apt-get -y install phonon-backend-vlc

sudo apt-get install libflann-dev

cd pcl

mkdir release
cd release
sudo cmake -DCMAKE_BUILD_TYPE=None -DBUILD_GPU=ON -DBUILD_apps=ON -DBUILD_examples=ON ..
sudo make -j 4

sudo make -j 4 install
