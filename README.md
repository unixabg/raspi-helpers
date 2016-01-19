# raspi-helpers
## Scripts to assist some tasks on the Raspberry Pi 2.

### scripts/jasper-installer.sh
##### Install Raspbian Lite something like the following
###### ** Where /dev/sdX is your target (BE CAREFUL) **

`sudo dd if=/path/to/raspbian/image/2015-11-21-raspbian-jessie-lite.img of=/dev/sdX bs=2M`

###### Flush any writes pending.
`sudo sync`

##### Boot the fresh install

##### Expand for raspbian to use entire disk with
##### (select to reboot now when prompted)

`sudo raspi-config`

##### Upon reboot you could clone the repository or just download the script
##### Below is if you want to download the script

`wget https://raw.githubusercontent.com/unixabg/raspi-helpers/master/scripts/jasper-installer.sh`

`chmod +x jasper-installer.sh`

##### Run the script and this can take several hours

`~/jasper-installer.sh`


FIXME

