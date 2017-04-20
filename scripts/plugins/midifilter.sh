#!/bin/sh

cd $LV2_SRC_DIR
git clone git://github.com/x42/midifilter.lv2.git
cd midifilter.lv2
sed -i -- 's/-msse -msse2 -mfpmath=sse//' Makefile
sed -i -- 's/LV2DIR ?= \$(PREFIX)\/lib\/lv2/LV2DIR ?= \/usr\/local\/modep\/.lv2/' Makefile
make -j 4 MOD=modep
sudo make MOD=modep install
make clean
cd ..