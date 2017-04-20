#!/bin/sh

cd $LV2_SRC_DIR
git clone https://github.com/moddevices/mod-distortion.git
cd mod-distortion
cd ds1
make -j 4
sudo make INSTALL_PATH=$LV2_DIR install
make clean
cd ..
cd bigmuff
make -j 4
sudo make INSTALL_PATH=$LV2_DIR install
make clean
cd ..
cd ..