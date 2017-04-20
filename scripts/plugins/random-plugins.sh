#!/bin/sh

echo "installing GxSlowGear plugin.."
cd $LV2_SRC_DIR
git clone https://github.com/moddevices/GxSlowGear.lv2.git
cd GxSlowGear.lv2
sed -i -- 's/-msse2 -mfpmath=sse//' Makefile
make -j 4
sudo make INSTALL_DIR=$LV2_DIR install
make clean
cd ..
echo "installing GxSwitchlessWah plugin.."
cd $LV2_SRC_DIR
git clone https://github.com/moddevices/GxSwitchlessWah.lv2.git
cd GxSwitchlessWah.lv2
sed -i -- 's/-msse2 -mfpmath=sse//' Makefile
make -j 4
sudo make INSTALL_DIR=$LV2_DIR install
make clean
cd ..