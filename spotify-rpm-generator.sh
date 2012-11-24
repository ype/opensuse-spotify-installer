#!/bin/sh

# Author: Marguerite Su <i@marguerite.su>
# License: GPL-3.0
# Version: 1.0
# Description: Shell Scripts used to build and install Spotify standard RPM for openSUSE.

# need root permission

if [[ $UID -ne 0 ]]
then
        echo "Only root can run this script!"
        exit 1
fi

# define spotify parameters

SPOTIFY_VERSION=0.8.4.103.g9cb177b.260-1

if [ `uname -m` == 'x86_64' ]; then
        SPOTIFY_ARCH=amd64
else
        SPOTIFY_ARCH=i386
fi

# check if we have 'rpmbuild' package installed, if not then install it.

if [[ `rpm -qa rpm-build` != "" ]] ; then
	zypper install --no-refresh rpm-build # 'rpm-build' is in oss, so no need to refresh that long.
fi

# prepare for the build environment.

# download specfile from github
cd /usr/src/packages/SPECS/
wget https://raw.github.com/marguerite/opensuse-spotify-installer/master/spotify.spec

# download source deb
cd ../SOURCES/

echo "If you already have spotify deb, please press 'ctrl + c',\n
put it under your home, and restart this script.\n
or else we'll download it (may take a long time)."

sleep 5

echo "Downloading..."
	
test -x spotify-client_${SPOTIFY_VERSION}_$SPOTIFY_ARCH.deb || wget http://repository.spotify.com/pool/non-free/s/spotify/spotify-client_${SPOTIFY_VERSION}_$SPOTIFY_ARCH.deb

# build

echo "Building..."

cd ../SPECS/
rpmbuild -ba spotify.spec

echo "Build done! Cleaning..."

# clean

## copy generated rpm

NORMAL_USER=`logname`

if [ $ARCH == '1' ]; then
	cp -r ../RPMS/x86_64/*.rpm /home/$NORMAL_USER/
else
	cp -r ../RPMS/i586/*.rpm /home/$NORMAL_USER/
fi
     

## real clean
rm -rf /usr/src/packages/SOURCES/*
rm -rf /usr/src/packages/BUILD/*
rm -rf /usr/src/packages/BUILDROOT/*
rm -rf /usr/src/packages/RPM/i586/*
rm -rf /usr/src/packages/RPM/x86_64/*
rm -rf /usr/src/packages/SRPM/*
rm -rf /usr/src/packages/SPECS/*

# install

## dependencies

echo "Resolving dependencies..."

! [ `rpm -qa mozilla-nss` ] && zypper install --no-refresh mozilla-nss
! [ `rpm -qa mozilla-nspr` ] && zypper install --no-refresh mozilla-nspr
! [ `rpm -qa libopenssl1_0_0` ] && zypper install --no-refresh libopenssl1_0_0

echo "Installing..."

rpm -ivh --force --nodeps /home/$NORMAL_USER/spotify-*.rpm

echo "Congrats! Installation finished.\n
We put the generated RPM under your home.\n
Next time you can use `sudo rpm -ivh --force --nodeps spotify-*.rpm` or\n
`sudo zypper install --no-refresh --force-resolution` to install it."

# quit

echo "Quitting..."

exit 0

