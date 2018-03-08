#!/bin/bash

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

HOME=/home/pi
MODEP=/usr/local/modep

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install git
cd $HOME
if [ ! -d "modep" ]; then
	echo "Cloning modep repository..."
	git clone https://github.com/BlokasLabs/modep.git
else
	echo "Updating modep repository..."
	cd modep
	git pull
	cd ..
fi
sudo mkdir -p $MODEP
sudo chmod 777 -R $MODEP
sudo cp -r $HOME/modep/scripts $MODEP/
sudo cp -r $HOME/modep/data $MODEP/
sudo cp -r $HOME/modep/services $MODEP/
sudo mv $MODEP/scripts/modep.sh $MODEP/modep.sh
sudo chmod +x $MODEP/modep.sh
if ! grep -q 'alias modep="/usr/local/modep/modep.sh"' $HOME/.bashrc; then
	echo 'alias modep="/usr/local/modep/modep.sh"' >> $HOME/.bashrc
	source $HOME/.bashrc
fi
sudo systemctl daemon-reload
sudo apt-get clean
$MODEP/modep.sh
