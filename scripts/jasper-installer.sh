#!/bin/sh

## jasper-installer.sh - Script designed to install jasper on raspbian.
## Copyright (C) 2016 Richard Nelson <unixabg@gmail.com>
##
## This program comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.

set -e
#set -x

Defaults () {
	# Function for Defaults
	echo "$(date) - Called Defaults..." >> ~/jasper-installer.log
	echo "$(date) - Start jasper-installer script." >> ~/jasper-installer.log
	echo "$(date) - Update raspbian..." >> ~/jasper-installer.log
	# Update raspbian
	sudo apt-get update
	sudo apt-get upgrade --yes

	echo "$(date) - Append PATH var and export LD_LIBRARY_PATH..." >> ~/jasper-installer.log
	# Append PATH var and export LD_LIBRARY_PATH
	cat <<EOT >> /home/pi/.bashrc
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib
PATH=$PATH:/usr/local/lib/
export PATH
EOT
}

JasperBase () {
	# Function to install Jasper base
	echo "$(date) - Called JasperBase..." >> ~/jasper-installer.log
	echo "$(date) - Checkout Jasper from git..." >> ~/jasper-installer.log
	# Checkout Jasper from git
	git clone https://github.com/jasperproject/jasper-client.git jasper
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
}

JasperLocal () {
	# Function to install Jasper local
	echo "$(date) - Called JasperLocal..." >> ~/jasper-installer.log
	echo "$(date) - Install the dependencies for Jasper local..." >> ~/jasper-installer.log
	echo "$(date) - Download and extract packages for STT..." >> ~/jasper-installer.log
	# Download and extract packages for STT
	# The Pocketsphinx STT engine requires the MIT Language Modeling Toolkit,
	# m2m-aligner, Phonetisaurus
	cd ~
	wget http://downloads.sourceforge.net/project/cmusphinx/sphinxbase/0.8/sphinxbase-0.8.tar.gz
	wget http://downloads.sourceforge.net/project/cmusphinx/pocketsphinx/0.8/pocketsphinx-0.8.tar.gz
	wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/mitlm/mitlm-0.4.1.tar.gz
	wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/m2m-aligner/m2m-aligner-1.2.tar.gz
	wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/phonetisaurus/is2013-conversion.tgz
	wget https://www.dropbox.com/s/kfht75czdwucni1/g014b2b.tgz
	svn co https://svn.code.sf.net/p/cmusphinx/code/trunk/cmuclmtk/
	tar xvf sphinxbase-0.8.tar.gz
	tar xvf pocketsphinx-0.8.tar.gz
	tar xvf m2m-aligner-1.2.tar.gz
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
}

JasperTools () {
	# Function to install Jasper tools
	echo "$(date) - Called JasperTools..." >> ~/jasper-installer.log
	echo "$(date) - Install the dependencies and some other packages..." >> ~/jasper-installer.log
	# Install the dependencies and some other packages
	sudo apt-get install vim git-core python-dev python-pip bison libasound2-dev libportaudio-dev python-pyaudio espeak subversion autoconf libtool automake gfortran g++ libfst-dev libfst-tools libfst1 --yes
}

JasperTweaks () {
	## Modify the CHUNK in jasper/client/mic.py
	#sed -i.bak -e's/1024/768/' ~/jasper/client/mic.py

	echo "$(date) - Modify the default sound card in jasper/client/tts.py..." >> ~/jasper-installer.log
	# Modify the default sound card in jasper/client/tts.py
	sed -i.bak -e's/plughw:1,0/plughw:0,0/' ~/jasper/client/tts.py

	echo "$(date) - Adjust the sound card defalut in alsa.conf..." >> ~/jasper-installer.log
	# Adjust the sound card defalut in alsa.conf
	#sudo sed -i.bak -e's/defaults.ctl.card 0/defaults.ctl.card 1/' /usr/share/alsa/alsa.conf
	sudo sed -i.bak -e's/defaults.pcm.card 0/defaults.pcm.card 1/' /usr/share/alsa/alsa.conf

	#echo "$(date) - Install crontab FIXME..." >> ~/jasper-installer.log
	## Install crontab
	#(crontab -u pi -l; echo '@reboot /home/pi/jasper/jasper.py') | sudo crontab -u pi -
}

JasperVoice () {
	# Function to install female voice for Jasper
	echo "$(date) - Called JasperVoice..." >> ~/jasper-installer.log
	echo "$(date) - Install svox tools for female voice..." >> ~/jasper-installer.log
	sudo apt-get install libttspico-data libttspico-utils libttspico0 --yes
}


_STT="NETWORK"

cat << EOF
######################################################
Welcome to the jasper-installer.sh script.
######################################################

######################################################
The installer script can install Jasper with or
without local Speech To Text (STT) support. By default
the jasper-installer.sh script will assume you want
network based STT. If you want local STT please answer
the question accordingly.

Select the desired STT support of (NETWORK or LOCAL)
(default: ${_STT})

EOF

# Ask for _STT
echo -n ": "
read _READ

_STT=${_READ:-${_STT}}


_SVOX="FEMALE"

cat << EOF
######################################################
The installer script can install Jasper with a female
voice for Text To Speech (TTS) support. By default the
jasper-installer.sh script will assume you want a
femal voice. If you want the regular Jasper male voice
please answer the question accordingly.

Select the desired voice for TTS support of (FEMALE or MALE)
(default: ${_SVOX})

EOF

# Ask for _SVOX
echo -n ": "
read _READ

_SVOX=${_READ:-${_SVOX}}


Defaults
JasperTools
JasperBase

# Here we include the building of STT tools local
if [ "${_STT}" = "LOCAL" ]
then
	echo "$(date) - User selected LOCAL STT option..." >> ~/jasper-installer.log
	JasperLocal
else
	echo "$(date) - User selected NETWORK STT option..." >> ~/jasper-installer.log
fi

# Here we include the voice for TTS
if [ "${_SVOX}" = "MALE" ]
then
	echo "$(date) - User selected MALE TTS voice..." >> ~/jasper-installer.log
else
	# Here we default to FEMALE for everything else entered.
	echo "$(date) - User selected FEMALE TTS voice..." >> ~/jasper-installer.log
	JasperVoice
fi

JasperTweaks

echo "$(date) - Jasper install attempt completed..." >> ~/jasper-installer.log
echo "$(date) - Jasper install attempt completed."
echo "$(date) - Please remember to run the following to configure Jasper:"
echo
echo 'python ~/jasper/client/populate.py'
echo
echo 'Also please reboot your computer once for good measure.'
echo 'Thanks for trying jasper-installer.sh script.'

#echo "$(date) - Populate the ~/.jasper/FIXME..." >> ~/jasper-installer.log
## Populate the ~/.jasper/FIXME
#cd ~/jasper/client
#python populate.py

#echo "$(date) - Reboot for jasper launch..." >> ~/jasper-installer.log
## Reboot for jasper launch
#sudo reboot

exit 0
