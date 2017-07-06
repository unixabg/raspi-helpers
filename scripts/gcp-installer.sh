#!/bin/bash
set -e

# Raspberry Pi Google Cloud Print Connector Installation Script

print_help() {
	echo "Usage: bash gcp-installer.sh OPTION"
	echo -e "\nOPTIONS:"
	echo -e "  --install\tInstall Google Cloud Print Connector"
	echo -e "  --remove\tAttempt to remove currently installed version"
}

if [ "$1" == "--install" ]; then
	clear

	echo "======================================================="
	echo "=== Setting up Raspberry Pi for Google Cloud Print  ==="
	echo "======================================================="

	read -r -p "This script will make changes to your system which may break some applications and may require you to reimage your SD card. Are you sure that you wish to continue? [y/N] " confirm

	if [[ $confirm =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		echo "Making a scratch-gcp directory."
		mkdir ~/scratch-gcp
		cd ~/scratch-gcp

		echo "Downloading go install script."
		wget https://raw.githubusercontent.com/unixabg/golang-tools-install-script/master/goinstall.sh -O ~/scratch-gcp/goinstall.sh
		chmod +x ~/scratch-gcp/goinstall.sh

		echo "Attempting to install go."
		~/scratch-gcp/goinstall.sh --arm

		echo "Sourcing in .bashrc after go install."
		. ~/.bashrc

		echo "Attempting to build the Google Cloud Print connector utility, gcp-connector-util."
		go get github.com/google/cloud-print-connector/gcp-connector-util

		echo "Attempting to build the Google Cloud Print cups connector, gcp-cups-connector."
		go get github.com/google/cloud-print-connector/gcp-cups-connector

		echo "Making a gcp directory."
		mkdir ~/gcp

		echo "Moving the gcp binaries to the gcp folder."
		mv ~/go/bin/gcp* ~/gcp/

		echo "Configuring the json file for gcp with the gcp-connector-util."
		cd ~/gcp
		./gcp-connector-util i

		echo "Creating crontab."
		echo "Collecting current cron information."
		echo "Making original cron backup."
		crontab -l > ~/gcp/original.cron
		crontab -l > ~/gcp/gcp.cron
		echo "Adding gcp for startup on reboot."
		echo "@reboot ~/gcp/gcp-cups-connector -config-filename ~/gcp/gcp-cups-connector.config.json &" >> ~/gcp/gcp.cron
		echo "Installing crontabs."
		crontab ~/gcp/gcp.cron

		echo "Building attempt complete starting cleanup."
		echo "Removing go."
		~/scratch-gcp/goinstall.sh --remove

		echo "Removing scratch-gcp directory."
		rm -rf ~/scratch-gcp

		echo "Build, install, and cleanup complete."
		echo "Your install location is ~/gcp ."
		exit 0
	else
		echo "No action taken exiting script."
		exit 0
	fi
elif [ "$1" == "--remove" ]; then
	echo "FIXME --remove."
	if [ -d "$HOME/gcp" ]; then
		echo "Attempting to restore original cron."
		crontab ~/gcp/original.cron

		echo "Removing gcp directory."
		rm -rf ~/gcp
	fi
	if [ -d "$HOME/scratch-gcp" ]; then
		echo "Attempting to remove go."
		wget https://raw.githubusercontent.com/unixabg/golang-tools-install-script/master/goinstall.sh -O ~/scratch-gcp/goinstall.sh
		chmod +x ~/scratch-gcp/goinstall.sh
		~/scratch-gcp/goinstall.sh --remove

		echo "Removing scratch-gcp directory."
		rm -rf ~/scratch-gcp
	fi
	exit 0
elif [ "$1" == "--help" ]; then
	print_help
	exit 0
else
	print_help
	exit 1
fi


