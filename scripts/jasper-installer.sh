#!/bin/sh

## jasper-installer.sh - Script designed to install jasper on raspbian.
## Copyright (C) 2016 Richard Nelson <unixabg@gmail.com>
##
## This program comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.

set -e
#set -x

echo "$(date) - Start jasper-installer script." >> ~/jasper-installer.log

echo "$(date) - Update raspbian..." >> ~/jasper-installer.log
# Update raspbian
sudo apt-get update
sudo apt-get upgrade --yes

echo "$(date) - Install the dependencies and some other packages..." >> ~/jasper-installer.log
# Install the dependencies and some other packages
sudo apt-get install vim git-core python-dev python-pip bison libasound2-dev libportaudio-dev python-pyaudio espeak subversion autoconf libtool automake gfortran g++ --yes

echo "$(date) - Append PATH var and export LD_LIBRARY_PATH..." >> ~/jasper-installer.log
# Append PATH var and export LD_LIBRARY_PATH
cat <<EOT >> /home/pi/.bashrc
LD_LIBRARY_PATH="/usr/local/lib"
export LD_LIBRARY_PATH
PATH=$PATH:/usr/local/lib/
export PATH
EOT

echo "$(date) - Source in the .bashrc for the script..." >> ~/jasper-installer.log
# Source in the .bashrc for the script
. /home/pi/.bashrc

echo "$(date) - Download and extract packages for STT..." >> ~/jasper-installer.log
# Download and extract packages for STT
# The Pocketsphinx STT engine requires the MIT Language Modeling Toolkit,
# m2m-aligner, Phonetisaurus and OpenFST
cd ~
wget http://downloads.sourceforge.net/project/cmusphinx/sphinxbase/0.8/sphinxbase-0.8.tar.gz
wget http://downloads.sourceforge.net/project/cmusphinx/pocketsphinx/0.8/pocketsphinx-0.8.tar.gz
wget http://distfiles.macports.org/openfst/openfst-1.3.4.tar.gz
wget https://mitlm.googlecode.com/files/mitlm-0.4.1.tar.gz
wget https://m2m-aligner.googlecode.com/files/m2m-aligner-1.2.tar.gz
wget https://phonetisaurus.googlecode.com/files/is2013-conversion.tgz
wget https://www.dropbox.com/s/kfht75czdwucni1/g014b2b.tgz
svn co https://svn.code.sf.net/p/cmusphinx/code/trunk/cmuclmtk/
git clone https://github.com/jasperproject/jasper-client.git jasper
tar xvf sphinxbase-0.8.tar.gz
tar xvf pocketsphinx-0.8.tar.gz
tar xvf m2m-aligner-1.2.tar.gz
tar xvf openfst-1.3.4.tar.gz
tar xvf is2013-conversion.tgz
tar xvf mitlm-0.4.1.tar.gz
tar xvf g014b2b.tgz

echo "$(date) - Install Speech-To-Text Engine Pocketsphinx and CMUCLMTK..." >> ~/jasper-installer.log
# Install Speech-To-Text Engine Pocketsphinx and CMUCLMTK
cd ~/sphinxbase-0.8/
./configure --enable-fixed && make && sudo make install
cd ~/pocketsphinx-0.8/
./configure && make && sudo make install
cd ~/cmuclmtk/
sudo ./autogen.sh && sudo make && sudo make install

echo "$(date) - Install OpenFST..." >> ~/jasper-installer.log
# Install OpenFST
cd ~/openfst-1.3.4/
sudo ./configure --enable-compact-fsts --enable-const-fsts --enable-far --enable-lookahead-fsts --enable-pdt
sudo make install

echo "$(date) - Install M2M, MITLMT, Phonetisaurus and Phonetisaurus FST..." >> ~/jasper-installer.log
# Install M2M, MITLMT, Phonetisaurus and Phonetisaurus FST
cd ~/m2m-aligner-1.2/
sudo make
cd ~/mitlm-0.4.1/
sudo ./configure && sudo make install
cd ~/is2013-conversion/phonetisaurus/src/
make
cd ~/g014b2b/
./compile-fst.sh
cd
mv ~/g014b2b ~/phonetisaurus
sudo cp ~/m2m-aligner-1.2/m2m-aligner /usr/local/bin/m2m-aligner
sudo cp ~/is2013-conversion/bin/phonetisaurus-g2p /usr/local/bin/phonetisaurus-g2p
#sudo reboot

echo "$(date) - Install Jasper requirements..." >> ~/jasper-installer.log
# Install Jasper requirements
# First upgrade pip
sudo easy_install pip

# Now begin
cd ~
sudo pip install --upgrade setuptools
sudo pip install -r ~/jasper/client/requirements.txt
chmod +x jasper/jasper.py

echo "$(date) - Adding support for Google STT..." >> ~/jasper-installer.log
# Adding support for Google STT
sudo apt-get install python-pymad --yes
sudo pip install --upgrade gTTS

## Modify the CHUNK in jasper/client/mic.py
#sed -i.bak -e's/1024/768/' ~/jasper/client/mic.py

echo "$(date) - Modify the default sound card in jasper/client/tts.py..." >> ~/jasper-installer.log
# Modify the default sound card in jasper/client/tts.py
sed -i.bak -e's/plughw:1,0/plughw:0,0/' ~/jasper/client/tts.py

echo "$(date) - Adjust the sound card defalut in alsa.conf..." >> ~/jasper-installer.log
# Adjust the sound card defalut in alsa.conf
sudo sed -i.bak -e's/defaults.ctl.card 0/defaults.ctl.card 1/' /usr/share/alsa/alsa.conf
sudo sed -i.bak -e's/defaults.pcm.card 0/defaults.pcm.card 1/' /usr/share/alsa/alsa.conf

echo "$(date) - Populate the ~/.jasper/FIXME..." >> ~/jasper-installer.log
# Populate the ~/.jasper/FIXME
cd ~/jasper/client
python populate.py

#echo "$(date) - Install crontab FIXME..." >> ~/jasper-installer.log
# Install crontab FIXME


echo "$(date) - Reboot for jasper launch..." >> ~/jasper-installer.log
# Reboot for jasper launch
sudo reboot

exit 0
