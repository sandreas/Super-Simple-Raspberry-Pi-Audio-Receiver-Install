#!/bin/bash
# Prompt User for Installation
# Sets Log File
log="./install.log"
# Begins Logging
echo "" > $log
MYNAME=raspberrypi
AirPlay="y"
Bluetooth="y"
AP="n"
Kodi="n"
Lirc="n"
SoundCardInstall="n"
GMedia="n"


# Prompts the User to check whether or not to use individual names for the chosen devices
SameName="y"
while [ $SameName != "y" ] && [ $SameName != "n" ];
do
	read -p "Do you want all the Devices to use the same name? (y/n) : " SameName
done
if [ $SameName = "y" ]
then
	# Asks for All Devices Identical Name
	#read -p "Device name: " MYNAME
	APName=$MYNAME
	BluetoothName=$MYNAME
	AirPlayName=$MYNAME
	GMediaName=$MYNAME
elif [ $SameName = "n" ]
then	
	# Asks for Bluetooth Device Name
	if [ $Bluetooth = "y" ]
	then
		read -p "Bluetooth Device Name: " BluetoothName
	fi
	# Asks for AirPlay Device Name
	if [ $AirPlay = "y" ]
	then
		read -p "AirPlay Device Name: " AirPlayName
	fi
	# Asks for Access Point Device Name
	if [ $AP = "y" ]
	then
		read -p "Access Point Device Name: " APName
	fi
	if [ $GMedia = "y" ]
	then
		read -p "UPnP Device Name: " GMediaName	
	fi
fi
if [ $AP = "y" ]
then
# Asks for the Access Point Password
read -p "Device WiFi Password: " WIFIPASS
fi
if [ $SoundCardInstall = "y" ]
then
	echo "0. No Sound Card"
	echo "1. HifiBerry DAC Light"
	echo "2. HifiBerry DAC Standard/Pro"
	echo "3. HifiBerry Digi+"
	echo "4. Hifiberry Amp+"
	echo "5. Pi-IQaudIO DAC"
	echo "6. Pi-IQaudIO DAC+, Pi-IQaudIO DACZero, Pi-IQaudIO DAC PRO"
	echo "7. Pi-IQaudIO DigiAMP"
	echo "8. Pi-IQaudIO Digi+"
	echo "9. USB Sound Card"
	echo "10. JustBoom DAC and AMP Cards"
	echo "11. JustBoom Digi Cards"
	SoundCard="SoundCard"
	while [ $SoundCard != "0" ] && [ $SoundCard != "1" ] && [ $SoundCard != "2" ] && [ $SoundCard != "3" ] && [ $SoundCard != "4" ] && [ $SoundCard != "5" ] && [ $SoundCard != "6" ] && [ $SoundCard != "7" ] && [ $SoundCard != "8" ] && [ $SoundCard != "9" ] && [ $SoundCard != "10" ] && [ $SoundCard != "11" ];
	do
		read -p "Which Sound Card are you using? (0/1/2/3/4/5/6/7/8/9/10/11) : " SoundCard
	done
else
	SoundCard="0"
fi

#--------------------------------------------------------------------
function tst {
    echo "===> Executing: $*"
    if ! $*; then
        echo "Exiting script due to error from: $*"
        exit 1
    fi
}
#--------------------------------------------------------------------
chmod +x ./*
echo "Starting @ `date`" | tee -a $log
# Updates and Upgrades the Raspberry Pi
echo "--------------------------------------------" | tee -a $log
tst ./bt_pa_prep.sh | tee -a $log
echo "--------------------------------------------" | tee -a $log
# If Bluetooth is Chosen, it installs Bluetooth Dependencies and issues commands for proper configuration
if [ $Bluetooth = "y" ]
then
	tst ./bt_pa_install.sh | tee -a $log
	echo "--------------------------------------------" | tee -a $log
	echo "${BluetoothName}" | tst ./bt_pa_config.sh | tee -a $log
	echo "--------------------------------------------" | tee -a $log
fi
if [ $SoundCardInstall = "y" ]
then
	echo "${SoundCard}" | tst ./sound_card_install.sh | tee -a $log
	echo "--------------------------------------------" | tee -a $log
fi
# If AirPlay is Chosen, it installs AirPlay Dependencies and issues commands for proper configuration
if [ $AirPlay = "y" ]
then
	tst ./airplay_install.sh | tee -a $log
	echo "--------------------------------------------" | tee -a $log
	{ echo "${AirPlayName}"; echo "${SoundCard}";} | tst ./airplay_config.sh | tee -a $log
	echo "--------------------------------------------" | tee -a $log
fi
# If Access Point is Chosen, it installs AP Dependencies and issues commands for proper configuration
if [ $AP = "y" ]
then
	tst ./ap_install.sh | tee -a $log
	echo "--------------------------------------------" | tee -a $log
	{ echo "${APName}"; echo "${WIFIPASS}";} | tst ./ap_config.sh | tee -a $log
	echo "--------------------------------------------" | tee -a $log
fi
# If Kodi is Chosen, it installs Kodi Dependencies and issues commands for proper configuration
if [ $Kodi = "y" ]
then
	tst ./kodi_install.sh | tee -a $log
	echo "--------------------------------------------" | tee -a $log
	tst ./kodi_config.sh | tee -a $log
	echo "--------------------------------------------" | tee -a $log
fi
# If Lirc is Chosen, it installs Lirc Dependencies and issues commands for proper configuration
if [ $Lirc = "y" ]
then
	tst ./lirc_install.sh | tee -a $log
	echo "--------------------------------------------" | tee -a $log
	tst ./lirc_config.sh | tee -a $log
	echo "--------------------------------------------" | tee -a $log
fi
# If GMedia is Chosen, it installs  GMedia Dependencies and issues commands for proper configuration
if [ $GMedia = "y" ]
then
	echo "${GMediaName}" | tst ./gmrender_install.sh | tee -a $log
	echo "--------------------------------------------" | tee -a $log
fi
echo "Ending at @ `date`" | tee -a $log
reboot
