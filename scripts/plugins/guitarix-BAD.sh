#!/bin/sh

# Copyright (C) 2017 Vilniaus Blokas UAB, http://blokas.io/
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 2 of the
# License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

cd $LV2_SRC_DIR
for i in gettext intltool gettext-devel libglib2.0-dev libsndfile1-dev libglibmm-2.4-dev libfftw3-dev libeigen3-dev; do
  sudo apt-get install -y $i
done
git clone http://git.code.sf.net/p/guitarix/git guitarix-git
cd guitarix-git/trunk
./waf configure --no-lv2-gui --lv2-only --disable-sse --lv2dir=$LV2_DIR --no-avahi --no-bluez --no-ladspa --no-faust 
./waf build
sudo ./waf install
./waf clean
cd ../..
