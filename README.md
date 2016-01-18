# raspi-helpers
## Scripts to assist some tasks on the Raspberry Pi 2.

### scripts/jasper-installer.sh
#### Install Raspbian Lite something like the following
#### ** Where /dev/sdX is your target (BE CAREFUL) **

`sudo dd if=/path/to/raspbian/image/2015-11-21-raspbian-jessie-lite.img of=/dev/sdX bs=2M`
'sudo sync'

### Boot the fresh install
### Expand to use entire disk with and select to reboot now when prompted
`sudo raspi-config`

FIXME

