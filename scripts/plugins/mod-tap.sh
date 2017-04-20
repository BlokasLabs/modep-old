#!/bin/sh

cd $LV2_SRC_DIR
git clone https://github.com/BlokasLabs/tap-lv2.git
cd tap-lv2
sed -i -- 's/-mtune=generic -msse -msse2 -mfpmath=sse//' Makefile.mk
make -j 4
sudo make INSTALL_PATH=$LV2_DIR install
make clean
cd ..
