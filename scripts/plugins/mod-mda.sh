#!/bin/sh

cd $LV2_SRC_DIR
git clone https://github.com/BlokasLabs/mda-lv2.git
cd mda-lv2
sudo ./waf configure --lv2-user --lv2dir=$LV2_DIR
sudo ./waf build
sudo ./waf -j1 install
sudo ./waf clean
cd ..
