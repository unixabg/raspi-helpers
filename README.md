# raspi-helpers
## Scripts to assist some tasks on the Raspberry Pi 2.

### scripts/jasper-installer.sh
- Script to assist installing Jasper on Raspbian Lite
- Tested on a fresh install of Jessie Raspbian Lite and expanded to use entire disk

#### Getting Started
- Upon reboot login as user pi
- Download the script with below command:

`wget https://raw.githubusercontent.com/unixabg/raspi-helpers/master/scripts/jasper-installer.sh`

- Make the script you just downloaded executable with the below command:

`chmod +x jasper-installer.sh`

- Launch the script and this can take several hours:

`~/jasper-installer.sh`

##### Force audio to headphone jack ref: https://www.raspberrypi.org/forums/viewtopic.php?f=91&t=40872

`sudo amixer cset numid=3 1`

FIXME

