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

# Setting MODEP dirs
export MODEP_DIR="/usr/local/modep"
export MODEP_SRC_DIR="$MODEP_DIR/src"
export LV2_DIR="$MODEP_DIR/.lv2"
export PEDALBOARDS_DIR="$MODEP_DIR/.pedalboards"
export LV2_SRC_DIR="$MODEP_SRC_DIR/lv2"


# INSTALL PART
install_pisound() {
	echo
	echo "$FUNCNAME started"
	echo
	cd $MODEP_SRC_DIR
	set -e
	if [ ! -d "pisound" ]; then
		echo "Cloning pisound repository from https://github.com/BlokasLabs/pisound..."
		git clone https://github.com/BlokasLabs/pisound.git
		cd pisound
	else
		echo "Updating pisound repository with latest stuff in https://github.com/BlokasLabs/pisound..."
		cd pisound
		git pull
	fi
	echo
	chmod +x enable-pisound.sh
	chmod +x disable-pisound.sh
	cd pisound-btn
	make
	sudo make install
	sudo ../enable-pisound.sh
	set +e
	PISOUND_OVERLAY_LOADED=`find /proc/device-tree/ 2> /dev/null | grep pisound | head -1`
	if [ -z $PISOUND_OVERLAY_LOADED ]; then
		echo "Loading pisound overlays dynamically!"
		sudo dtoverlay pisound
		sudo dtoverlay i2s-mmap
	else
		echo "pisound overlay is already loaded!"
	fi
	echo "setting pisound as the default audio device"
	if grep -q 'pcm.!default' ~/.asoundrc; then
		sed -i '/pcm.!default\|ctl.!default/,/}/ { s/type .*/type hw/g; s/card .*/card 1/g; }' ~/.asoundrc
	else
		printf 'pcm.!default {\n\ttype hw\n\tcard 1\n}\n\nctl.!default {\n\ttype hw\n\tcard 1\n}\n' >> ~/.asoundrc
	fi
	for btn in `ps -C btn --no-headers | awk '{print $1;}'`; do
		kill $btn > /dev/null
	done
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

install_hotspot() {
	check_pisound -s
	echo
	echo "$FUNCNAME started"
	echo
	cd $MODEP_SRC_DIR
	sudo apt-get install -y dnsmasq hostapd
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

install_touchosc() {
	echo
	echo "$FUNCNAME started"
	echo
	cd $MODEP_SRC_DIR
	sudo apt-get install -y python-pip python-setuptools libpython2.7-dev liblo-dev
	sudo easy_install --upgrade pip
	sudo pip install pgen
	sudo pip install Cython --install-option="--no-cython-compile"
	sudo pip install netifaces
	sudo pip install enum-compat
	sudo pip install touchosc2midi
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

install_jack() {
	echo
	echo "$FUNCNAME started"
	echo
	cd $MODEP_SRC_DIR
	sudo apt-get install -y libasound2-dev libsndfile1-dev libreadline-dev libreadline6-dev libtinfo-dev
	git clone https://github.com/jackaudio/jack2.git --depth 1
	cd jack2
	./waf configure
	./waf build
	sudo ./waf install
	sudo ldconfig
	cd ..
	echo
	if grep -q '@audio - memlock 256000' /etc/security/limits.conf; then
		echo "memlock already set"
	else
		sudo sh -c "echo @audio - memlock 256000 >> /etc/security/limits.conf"
		echo "setting memlock"
	fi
	if grep -q '@audio - rtprio 75' /etc/security/limits.conf; then
		echo "rtprio already set"
	else
		sudo sh -c "echo @audio - rtprio 75 >> /etc/security/limits.conf"
		echo "setting rtprio"
	fi
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

install_lilv() {
	echo
	echo "$FUNCNAME started"
	echo
	cd $MODEP_SRC_DIR
	git clone https://github.com/drobilla/lv2.git
	cd lv2
	./waf configure --no-plugins
	./waf build
	sudo ./waf install
	./waf clean
	cd ..
	echo
	git clone --recursive http://git.drobilla.net/serd.git/
	cd serd
	./waf configure
	./waf build
	sudo ./waf install
	./waf clean
	cd ..
	echo
	git clone --recursive http://git.drobilla.net/sord.git/
	cd sord
	./waf configure
	./waf build
	sudo ./waf install
	./waf clean
	cd ..
	echo
	git clone http://git.drobilla.net/sratom.git sratom
	cd sratom
	./waf configure
	./waf build
	sudo ./waf install
	./waf clean
	cd ..
	echo
	sudo apt-get -y install swig python3-numpy-dev
	git clone --recursive http://git.drobilla.net/lilv.git lilv
	cd lilv
	./waf configure
	./waf build
	sudo ./waf install
	./waf clean
	cd ..
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

install_modhost() {
	echo
	echo "$FUNCNAME started"
	echo
	cd $MODEP_SRC_DIR
	sudo apt-get install -y libreadline-dev
	git clone https://github.com/BlokasLabs/mod-host.git
	cd mod-host
	make -j 4
	sudo make install
	make clean
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

install_modui() {
	echo
	echo "$FUNCNAME started"
	echo
	cd $MODEP_DIR
	sudo apt-get install -y python3-pip
	git clone --recursive https://github.com/BlokasLabs/mod-ui.git
	cd mod-ui
	sudo pip3 install -r requirements.txt
	cd utils
	make
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

install_plugins() {
	#plugins To-Do
	#
	#calf-plugins
	#https://github.com/moddevices/mod-pitchshifter.git
	#https://github.com/moddevices/gx_voxtb.lv2.git
	#https://github.com/moddevices/GxVintageFuzzMaster.lv2.git
	#
	echo
	echo "$FUNCNAME started"
	echo
	echo "installing MOD CAPS suite.."
	sudo chmod +x $MODEP_DIR/scripts/plugins/mod-caps.sh
	$MODEP_DIR/scripts/plugins/mod-caps.sh
	echo
	echo "installing MOD MDA suite.."
	sudo chmod +x $MODEP_DIR/scripts/plugins/mod-mda.sh
	$MODEP_DIR/scripts/plugins/mod-mda.sh
	echo
	echo "installing MOD TAP suite.."
	sudo chmod +x $MODEP_DIR/scripts/plugins/mod-tap.sh
	$MODEP_DIR/scripts/plugins/mod-tap.sh
	echo
	echo "installing Midifilter suite.."
	sudo chmod +x $MODEP_DIR/scripts/plugins/midifilter.sh
	$MODEP_DIR/scripts/plugins/midifilter.sh
	echo
	echo "installing MOD Distortion suite.."
	sudo chmod +x $MODEP_DIR/scripts/plugins/mod-distortion.sh
	$MODEP_DIR/scripts/plugins/mod-distortion.sh
	echo
	echo "installing MOD Utilities suite.."
	sudo chmod +x $MODEP_DIR/scripts/plugins/mod-utilities.sh
	$MODEP_DIR/scripts/plugins/mod-utilities.sh
	echo
	echo "installing Freaked suite.."
	sudo chmod +x $MODEP_DIR/scripts/plugins/freaked.sh
	$MODEP_DIR/scripts/plugins/freaked.sh
	echo
	echo "installing FluidPlug suite.."
	sudo chmod +x $MODEP_DIR/scripts/plugins/fluid.sh
	$MODEP_DIR/scripts/plugins/fluid.sh
	echo "installing other plugins.."
	sudo chmod +x $MODEP_DIR/scripts/plugins/random-plugins.sh
	$MODEP_DIR/scripts/plugins/random-plugins.sh
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

install_pisoundbtn() {
	check_pisound -s
	echo
	echo "$FUNCNAME started"
	echo
	sudo chmod +x $MODEP_DIR/scripts/install-pisound-btn-scripts.sh
	sudo $MODEP_DIR/scripts/install-pisound-btn-scripts.sh
	echo
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

install_phantomjs() {
	echo
	echo "$FUNCNAME started"
	echo
	cd $MODEP_SRC_DIR
	sudo apt-get install -y libfontconfig1
	if [ ! -d "phantomjs-on-raspberry" ]; then
		echo "Cloning repository..."
		git clone https://github.com/fg2it/phantomjs-on-raspberry.git
	else
		echo "Updating repository with latest stuff..."
		cd phantomjs-on-raspberry
		git pull
		cd ..
	fi
	sudo /bin/cp -rf $MODEP_SRC_DIR/phantomjs-on-raspberry/rpi-2-3/wheezy-jessie/v2.1.1/phantomjs /usr/local/bin/phantomjs
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

install_all() {
	if [ -z "$1" ]; then
		if (whiptail --title "MOD Emulator for Pisound" --yesno "Ar you ready? It can take more than 40 minutes." $WT_HEIGHT $WT_WIDTH --fullbuttons); then
	    	:
		else
			return 0
		fi
	fi
	echo
	echo "$FUNCNAME started"
	echo
	sleep 1
	install_pisound -s
	check_pisound -s
	install_jack -s
	install_lilv -s
	install_hotspot -s
	install_touchosc -s
	install_modhost -s
	install_modui -s
	install_phantomjs -s
	install_pisoundbtn -s
	install_plugins -s
	enable_all_services -s
	change_hostname pisound
	change_password blokaslabs
	restore_modep_data -s
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Done! Thank you! New credentials [ user:pi psw:blokaslabs ]. Press any key to continue.."
	fi
}

# START-UP PART (needs some optimization)

enable_jack_service() {
	echo
	echo "$FUNCNAME started"
	echo
	sudo systemctl enable $MODEP_DIR/services/jack.service
	sudo systemctl start jack
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

enable_modhost_service() {
	echo
	echo "$FUNCNAME started"
	echo
	sudo systemctl enable $MODEP_DIR/services/mod-host.service
	sudo systemctl start mod-host
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

enable_modmonitor_service() {
	echo
	echo "$FUNCNAME started"
	echo
	sudo systemctl enable $MODEP_DIR/services/mod-monitor.service
	sudo systemctl start mod-monitor
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

enable_modui_service() {
	echo
	echo "$FUNCNAME started"
	echo
	sudo systemctl enable $MODEP_DIR/services/mod-ui.service
	sudo systemctl start mod-ui
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

enable_hotspot_service() {
	echo
	echo "$FUNCNAME started"
	echo
	sudo systemctl enable $MODEP_DIR/services/pisound-hotspot.service
	sudo systemctl start pisound-hotspot
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

enable_touchosc2midi_service() {
	echo
	echo "$FUNCNAME started"
	echo
	sudo systemctl enable $MODEP_DIR/services/touchosc2midi.service
	sudo systemctl start touchosc2midi
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

enable_all_services() {
	echo
	echo "$FUNCNAME started"
	enable_jack_service -s
	enable_modhost_service -s
	enable_modmonitor_service -s
	enable_modui_service -s
	enable_hotspot_service -s
	enable_touchosc2midi_service -s
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

disable_jack_service() {
	echo
	echo "$FUNCNAME started"
	echo
	sudo systemctl stop jack
	sudo systemctl disable jack.service
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

disable_modhost_service() {
	echo
	echo "$FUNCNAME started"
	echo
	sudo systemctl stop mod-host
	sudo systemctl disable mod-host.service
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

disable_modmonitor_service() {
	echo
	echo "$FUNCNAME started"
	echo
	sudo systemctl stop mod-monitor
	sudo systemctl disable mod-monitor.service
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

disable_modui_service() {
	echo
	echo "$FUNCNAME started"
	echo
	sudo systemctl stop mod-ui
	sudo systemctl disable mod-ui.service
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

disable_hotspot_service() {
	echo
	echo "$FUNCNAME started"
	echo
	sudo systemctl stop pisound-hotspot
	sudo systemctl disable pisound-hotspot.service
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

disable_touchosc2midi_service() {
	echo
	echo "$FUNCNAME started"
	echo
	sudo systemctl stop touchosc2midi
	sudo systemctl disable touchosc2midi.service
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

disable_all_services() {
	echo
	echo "$FUNCNAME started"
	disable_modui_service -s
	disable_modmonitor_service -s
	disable_modhost_service -s
	disable_jack_service -s
	disable_hotspot_service -s
	disable_touchosc2midi_service -s
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

# RANDOM PART

restore_modep_data() {
	echo
	echo "$FUNCNAME started"
	if [ ! -d "$MODEP_DIR/mod-ui/dados/" ]; then
		sudo mkdir $MODEP_DIR/mod-ui/dados/
	fi
	sudo /bin/cp -rf $MODEP_DIR/data/banks.json $MODEP_DIR/mod-ui/dados/banks.json
	echo "cp banks.json"
	if [ ! -d "$MODEP_DIR/.pedalboards/" ]; then
		sudo mkdir $MODEP_DIR/.pedalboards/
	fi
	sudo /bin/cp -rf $MODEP_DIR/data/pedalboards/* $MODEP_DIR/.pedalboards/
	echo "cp pedalboards"
	if [ $(systemctl is-enabled mod-ui) = "enabled" ]; then
		sudo  systemctl restart mod-ui
	fi
	if [ -z "$1" ]; then
		echo
		read -n 1 -p "Press any key to continue.."
	fi
}

check_system_status() {
	JACK_STATUS=`systemctl is-active jack`
	MODHOST_STATUS=`systemctl is-active mod-host`
	MODMONITOR_STATUS=`systemctl is-active mod-monitor`
	MODUI_STATUS=`systemctl is-active mod-ui`
	PISOUNDBTN_STATUS=`systemctl is-active pisound-btn`
	HOTSPOT_STATUS=`systemctl is-active pisound-hotspot`
	OSC2MIDI=`systemctl is-active touchosc2midi`

	whiptail --msgbox --title "MOD Emulator for Pisound" --fullbuttons "\
		jack.service $JACK_STATUS
		mod-host.service $MODHOST_STATUS
		mod-monitor.service $MODMONITOR_STATUS
		mod-ui.service $MODUI_STATUS
		pisound-btn.service $PISOUNDBTN_STATUS
		pisound-hotspot.service $HOTSPOT_STATUS
		touchosc2midi.service $OSC2MIDI \
		" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
}

check_pisound() {
	if [ -f /sys/kernel/pisound/version ]; then
		if [ -z "$1" ]; then
			echo ""
			echo "Pisound firmware version:"
			cat /sys/kernel/pisound/version
			echo ""
			read -n 1 -p "Press any key to continue.."
		fi
	else
		get_pisound_menu
		exit
	fi
}

should_reboot() {
	if [ $ASK_TO_REBOOT == 1 ]; then
		if [ -z "$1" ]; then
			if (whiptail --title "MOD Emulator for Pisound" --yesno "Reboot is required. Reboot now?" $WT_HEIGHT $WT_WIDTH --fullbuttons); then
		    	sudo reboot
				exit
			else
				exit
			fi
		else
			sudo reboot
			exit
		fi
	fi
}

create_dirs() {
	if [ ! -d "$MODEP_DIR" ]; then
		mkdir -p $MODEP_DIR/
	fi
	if [ ! -d "$MODEP_SRC_DIR" ]; then
		mkdir -p $MODEP_SRC_DIR/
	fi
	if [ ! -d "$LV2_DIR" ]; then
		sudo mkdir -p $LV2_DIR/
#		sudo ln -s $LV2_DIR /root/.lv2
	fi
	if [ ! -d "$PEDALBOARDS_DIR" ]; then
		sudo mkdir -p $PEDALBOARDS_DIR/
#		sudo ln -s $PEDALBOARDS_DIR /root/.pedalboards
	fi
	if [ ! -d "$LV2_SRC_DIR" ]; then
		mkdir -p $LV2_SRC_DIR/
	fi
}

clear_src() {
	if [ -z "$1" ]; then
		if (whiptail --title "MOD Emulator for Pisound" --yesno "Ar you sure?" $WT_HEIGHT $WT_WIDTH --fullbuttons); then
	    		sudo rm -rf $MODEP_SRC_DIR/*
		fi
	else
		sudo rm -rf $MODEP_SRC_DIR/*
	fi
}

wt_config() {
 	WT_HEIGHT=18
 	WT_WIDTH=54
 	WT_MENU_HEIGHT=$(($WT_HEIGHT-9))
}

change_hostname() {
	CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
	if [ -z "$1" ]; then
		NEW_HOSTNAME=$(whiptail --inputbox "Please enter a hostname" $WT_HEIGHT $WT_WIDTH --fullbuttons "$CURRENT_HOSTNAME" 3>&1 1>&2 2>&3)
	else
		NEW_HOSTNAME=$1
		true
	fi
	if [ $? -eq 0 ]; then
		echo $NEW_HOSTNAME | sudo tee /etc/hostname > /dev/null
		sudo sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts
		ASK_TO_REBOOT=1
	fi
}

change_password() {
	if [ -z "$1" ]; then
		NEW_PASSWORD=$(whiptail --inputbox "Please enter a password for user pi" $WT_HEIGHT $WT_WIDTH --fullbuttons "password" 3>&1 1>&2 2>&3)
	else
		NEW_PASSWORD=$1
		true
	fi
	if [ $? -eq 0 ]; then
		echo "pi:$NEW_PASSWORD" | sudo chpasswd
		ASK_TO_REBOOT=1
	fi
}

# GUI MENU PART

get_manual_setup_menu() {
	while (( !MANUAL_DONE )); do
		MANUAL_OPTION=$(whiptail --title "MOD Emulator for Pisound" --menu "" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button "Go Back" --ok-button Select --fullbuttons \
			"1" "Install Pisound HAT drivers" \
			"2" "Install Jack server" \
			"3" "Install LV2 libraries" \
			"4" "Install mod-host" \
			"5" "Install mod-ui webserver" \
			"6" "Install phantomjs binaries" \
			"7" "Install libraries for WiFi AP" \
			"8" "Install libraries for WiFi-MIDI" \
			"9" "Install LV2 plugins" \
			"10" "Install Pisound Button scripts" 3>&2 2>&1 1>&3 )

		RET=$?
		if [ $RET -eq 1 ]; then
			return 0
		elif [ $RET -eq 0 ]; then
			case $MANUAL_OPTION in
				1) install_pisound ;;
				2) install_jack ;;
				3) install_lilv ;;
				4) install_modhost ;;
				5) install_modui ;;
				6) install_phantomjs ;;
				7) install_hotspot ;;
				8) install_touchosc ;;
				9) install_plugins ;;
				10) install_pisoundbtn ;;
				*) whiptail --msgbox "Unrecognized option" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT ;;
			esac || whiptail --msgbox "Error running option $ADVANCED_OPTION" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
		fi
	done
}

get_disable_menu() {
	while (( !DISABLE_DONE )); do
		DISABLE_OPTION=$(whiptail --title "MOD Emulator for Pisound" --menu MODEP $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button "Go Back" --ok-button Select --fullbuttons \
			"1" "Disable all MODEP services" \
			"2" "Disable jack.service" \
			"3" "Disable mod-host.service" \
			"4" "Disable mod-monitor.service" \
			"5" "Disable mod-ui.service" \
			"6" "Disable pisound-hotspot.service" \
			"7" "Disable touchosc2midi.service" 3>&2 2>&1 1>&3 )

		case $DISABLE_OPTION in
			1) disable_all_services; return;;
			2) disable_jack_service ;;
			3) disable_modhost_service ;;
			4) disable_modmonitor_service ;;
			5) disable_modui_service ;;
			6) disable_hotspot_service ;;
			7) disable_touchosc2midi_service ;;
			*) DISABLE_DONE=1 ;;
		esac || whiptail --msgbox "Error running option $DISABLE_OPTION" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
	done
}

get_enable_menu() {
	while (( !ENABLE_DONE )); do
		ENABLE_OPTION=$(whiptail --title "MOD Emulator for Pisound" --menu MODEP $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button "Go Back" --ok-button Select --fullbuttons \
			"1" "Enable all MODEP services" \
			"2" "Enable jack.service" \
			"3" "Enable mod-host.service" \
			"4" "Enable mod-monitor.service" \
			"5" "Enable mod-ui.service" \
			"6" "Enable pisound-hotspot.service" \
			"7" "Enable touchosc2midi.service" 3>&2 2>&1 1>&3 )

		RET=$?
		if [ $RET -eq 1 ]; then
			return 0
		elif [ $RET -eq 0 ]; then

			case $ENABLE_OPTION in
				1) enable_all_services; return;;
				2) enable_jack_service ;;
				3) enable_modhost_service ;;
				4) enable_modmonitor_service ;;
				5) enable_modui_service ;;
				6) enable_hotspot_service ;;
				7) enable_touchosc2midi_service ;;
				*) whiptail --msgbox "Unrecognized option" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT ;;
			esac || whiptail --msgbox "Error running option $ENABLE_OPTION" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
		fi
	done
}

get_tools_menu() {
	while (( !TOOLS_DONE )); do
		TOOLS_OPTION=$(whiptail --title "MOD Emulator for Pisound" --menu "" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button "Go Back" --ok-button Select --fullbuttons \
			"1" "Check system status" \
			"2" "Check Pisound HAT version" \
			"3" "Enable MODEP systemd services" \
			"4" "Disable MODEP systemd services" \
			"5" "Change hostname (reboot required)" \
			"6" "Change password for user pi" \
			"7" "Clear build files" \
			"8" "Restore 'factory' data" 3>&2 2>&1 1>&3 )

		RET=$?
		if [ $RET -eq 1 ]; then
			return 0
		elif [ $RET -eq 0 ]; then
			case $TOOLS_OPTION in
				1) check_system_status ;;
				2) check_pisound ;;
				3) get_enable_menu ;;
				4) get_disable_menu ;;
				5) change_hostname ;;
				6) change_password ;;
				7) clear_src ;;
				8) restore_modep_data ;;
				*) whiptail --msgbox "Unrecognized option" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT ;;
			esac || whiptail --msgbox "Error running option $ADVANCED_OPTION" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
		fi
	done
}

get_about_menu() {
  whiptail --msgbox --title "MOD Emulator for Pisound" --fullbuttons " \
	This tool provides a straight-forward way of doing initial setup & config of the MOD Emulator for Pisound.

	Start with a fresh Raspbian OS image, as some of the steps may have difficulties if you have customised your system.

	If you like it - get the real thing at https://www.moddevices.com \
	" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
}

get_pisound_menu() {
  whiptail --msgbox --title "MOD Emulator for Pisound" --fullbuttons " \
	No Pisound HAT detected. Have you installed the drivers?

	More info at https://www.blokas.io \
	" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
}

# MAIN LOOP PART

ASK_TO_REBOOT=0

wt_config
create_dirs

ALL_DONE=0
if [ -z "$1" ]; then
	while (( !ALL_DONE )); do
		MAIN_OPTION=$(whiptail --title "MOD Emulator for Pisound" --menu "" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Exit --ok-button Select --fullbuttons \
			"1" "One-Click Setup" \
			"2" "Manual Setup" \
			"3" "Tools" \
			"4" "About" 3>&2 2>&1 1>&3 )

		RET=$?
		if [ $RET -eq 1 ]; then
			ALL_DONE=1
		elif [ $RET -eq 0 ]; then
			case $MAIN_OPTION in
				1) install_all ;;
				2) get_manual_setup_menu ;;
				3) get_tools_menu ;;
				4) get_about_menu ;;
				*) whiptail --msgbox "Unrecognized option" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT ;;
			esac || whiptail --msgbox "Error running option $MAIN_OPTION" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
		fi
	done
fi
should_reboot
