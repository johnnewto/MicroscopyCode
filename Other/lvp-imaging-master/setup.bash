#****************************************************************
# Fourier Ptychographic Imaging
# Setup File

# Author: Alankar Kotwal <alankarkotwal13@gmail.com>
#****************************************************************

# Make sure you're in the lvp-imaging directory

direc=${PWD##*/}

if [ "$direc" != "lvp-imaging" ]
then
	echo "Go to the lvp-imaging folder and execute the script."
	exit 0
else
	echo "Setting up..."
fi

#****************************************************************

# Get the  path of the repository in a file for MATLAB's sake

path=`pwd`
${path//\\/\\\\} > config/path

#****************************************************************

# Set up serial

sudo ln -s /dev/ttyACM0 /dev/ttyS101
sudo chmod 777 /dev/ttyS101

#****************************************************************

# Done!

echo "Done!"
