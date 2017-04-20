#!/bin/sh

cd $LV2_SRC_DIR
git clone https://github.com/pjotrompet/Freaked.git
cd Freaked
make -j 4 NOOPT=true
sed -i -- 's/\$(DESTDIR)\$(PREFIX)\/lib\/lv2\//\$(DESTDIR)/' Makefile
sudo make DESTDIR=$LV2_DIR install
make clean
sudo rm -rf $LV2_DIR/Freakclip.lv2
sudo rm -rf $LV2_DIR/Granulator.lv2
cd ..