#!/bin/sh

cd $LV2_SRC_DIR
git clone https://github.com/BlokasLabs/caps-lv2.git
cd caps-lv2
make -j 4
sudo cp -R plugins/* $LV2_DIR
make clean
sudo rm -rf $LV2_DIR/mod-caps-Eq4p.lv2
sudo rm -rf $LV2_DIR/mod-caps-EqFA4p.lv2
cd ..