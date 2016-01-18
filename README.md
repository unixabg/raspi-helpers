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

##### Upon reboot clone raspi-helpers

`sudo apt-get install git --yes`

`cd && git clone https://github.com/unixabg/raspi-helpers.git`

##### Run the script and this can take several hours

`~/raspi-helpers/scripts/jasper-installer.sh`


FIXME

