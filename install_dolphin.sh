#!/bin/bash

# Dolphin emulator installation script
# by digix
# 2012.12.11

DIR="/home/digix/sources/dolphin_install"
if [[ ! -d "$DIR" ]]; then
        mkdir "$DIR"
fi
cd $DIR

sudo apt-get update
sudo apt-get install cmake git g++ libgtk2.0-dev libsdl1.2-dev nvidia-cg-toolkit libxrandr-dev libxext-dev libglew1.6-dev libao-dev libasound2-dev libpulse-dev libbluetooth-dev libreadline-gplv2-dev libavcodec-dev libavformat-dev libswscale-dev

echo "Proceed with install?"
read answer

git clone https://code.google.com/p/dolphin-emu/ dolphin-emu

echo "Proceed with install?"
read answer

cd dolphin-emu
mkdir Build
cd Build
cmake ..

echo "Proceed with install?"
read answer

make
sudo make install
