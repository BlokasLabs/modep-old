#!/bin/sh

cd $LV2_SRC_DIR
sudo apt-get install -y autotools-dev automake libtool libglib2.0-dev
git clone https://git.code.sf.net/p/fluidsynth/code-git fluidsynth-code-git
cd fluidsynth-code-git/fluidsynth
sed -i '1s/^/m4_pattern_allow([AC_LIB_PROG_LD_GNU])\n/' configure.ac
sed -i -- 's/AM_INIT_AUTOMAKE(fluidsynth, \$FLUIDSYNTH_VERSION)/AM_INIT_AUTOMAKE(fluidsynth, \$FLUIDSYNTH_VERSION)\nAC_DEFINE(DEFAULT_SOUNDFONT, "share\/soundfonts\/default.sf2", \[Default soundfont\])/' configure.ac
./autogen.sh
./configure --disable-portaudio-support --disable-ladcca --disable-lash --disable-dart --disable-coremidi --disable-coreaudio --disable-aufile-support --disable-pulse-support --disable-alsa-support --disable-dbus-support  --disable-oss-support
make -j 4
sudo make install
sudo ldconfig
make clean
cd ../..
sudo apt-get install -y p7zip-full
cd $LV2_SRC_DIR
git clone https://github.com/falkTX/FluidPlug.git
cd FluidPlug/
sed -i -- 's/$(PREFIX)\/lib\/lv2//' Makefile
make -j 4 NOOPT=true
sudo make DESTDIR=$LV2_DIR NOOPT=true install
sudo rm -rf $LV2_DIR/Black_Pearl_4A.lv2
sudo rm -rf $LV2_DIR/Black_Pearl_4B.lv2
sudo rm -rf $LV2_DIR/Black_Pearl_5.lv2
sudo rm -rf $LV2_DIR/AVL_Drumkits_Perc.lv2
sudo rm -rf $LV2_DIR/Red_Zeppelin_4.lv2
sudo rm -rf $LV2_DIR/Red_Zeppelin_5.lv2
sudo ldconfig
make distclean
cd ..