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
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib
PATH=$PATH:/usr/local/lib/
export PATH
EOT

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

# Install Speech-To-Text Engine Pocketsphinx and CMUCLMTK
echo "$(date) - Building sphinxbase-0.8..." >> ~/jasper-installer.log
cd ~/sphinxbase-0.8/
./configure --enable-fixed
make -j2
sudo make install
echo "$(date) - Completed building and installing sphinxbase-0.8..." >> ~/jasper-installer.log

echo "$(date) - Building pocketshinx-0.8..." >> ~/jasper-installer.log
cd ~/pocketsphinx-0.8/
./configure
make -j2
sudo make install
echo "$(date) - Completed building and installing pocketshinx-0.8..." >> ~/jasper-installer.log

echo "$(date) - Building cmuclmtk..." >> ~/jasper-installer.log
cd ~/cmuclmtk/
./autogen.sh
make -j2
sudo make install
echo "$(date) - Completed building and installing cmuclmtk..." >> ~/jasper-installer.log

# Install OpenFST
echo "$(date) - Building openfst-1.3.4..." >> ~/jasper-installer.log
cd ~/openfst-1.3.4/
./configure --enable-compact-fsts --enable-const-fsts --enable-far --enable-lookahead-fsts --enable-pdt
make
sudo make install
echo "$(date) - Completed building and installing openfst-1.3.4..." >> ~/jasper-installer.log

# Install M2M, MITLMT, Phonetisaurus and Phonetisaurus FST
echo "$(date) - Building m2m-aligner-1.2..." >> ~/jasper-installer.log
cd ~/m2m-aligner-1.2/
make -j2
sudo cp ~/m2m-aligner-1.2/m2m-aligner /usr/local/bin/m2m-aligner
echo "$(date) - Completed building and installing m2m-aligner-1.2..." >> ~/jasper-installer.log

echo "$(date) - Building mitlm-0.4.1..." >> ~/jasper-installer.log
cd ~/mitlm-0.4.1/
./configure
make -j2
sudo make install
echo "$(date) - Completed building and installing mitlm-0.4.1..." >> ~/jasper-installer.log

echo "$(date) - Building is2013-conversion..." >> ~/jasper-installer.log
cd ~/is2013-conversion/phonetisaurus/src/
make -j2
sudo cp ~/is2013-conversion/bin/phonetisaurus-g2p /usr/local/bin/phonetisaurus-g2p
echo "$(date) - Completed building and installing is2013-conversion..." >> ~/jasper-installer.log

echo "$(date) - Building g014b2b..." >> ~/jasper-installer.log
echo "$(date) - Export the LD_LIBRARY_PATH for fstcompiler..." >> ~/jasper-installer.log
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib
cd ~/g014b2b/
./compile-fst.sh
cd
mv ~/g014b2b ~/phonetisaurus
echo "$(date) - Completed building and installing g014b2b..." >> ~/jasper-installer.log

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

echo "$(date) - Install crontab FIXME..." >> ~/jasper-installer.log
# Install crontab
echo "@reboot /home/pi/jasper/jasper.py" | crontab -

echo "$(date) - Reboot for jasper launch..." >> ~/jasper-installer.log
# Reboot for jasper launch
sudo reboot

exit 0
