#!/bin/sh

cd $LV2_SRC_DIR
git clone https://github.com/moddevices/mod-utilities.git
cd mod-utilities
make -j 4
sudo make INSTALL_PATH=$LV2_DIR install
make clean
cd ..
