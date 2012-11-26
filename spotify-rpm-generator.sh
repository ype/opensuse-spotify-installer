#!/bin/sh

# Author: Marguerite Su <i@marguerite.su>
# License: GPL-3.0
# Version: 1.0
# Description: Shell Scripts used to build and install Spotify standard RPM for openSUSE.

# need root permission

if [[ $UID -ne 0 ]]
then
        echo -e "\033[38;5;148mOnly root can run this script!\033[39m"
        exit 1
fi

# define spotify parameters

SPOTIFY_VERSION=0.8.4.103.g9cb177b.260-1

if [ `uname -m` == 'x86_64' ]; then
        SPOTIFY_ARCH=amd64
	RPM_ARCH=x86_64
else
        SPOTIFY_ARCH=i386
	RPM_ARCH=i586
fi

NORMAL_USER=`logname`

# check if we have 'rpmbuild' package installed, if not then install it.

if [[ `rpm -qa rpm-build` == "" ]] ; then
	zypper --no-refresh install rpm-build # 'rpm-build' is in oss, so no need to refresh that long.
fi

# prepare for the build environment.

# download specfile from github
cd /usr/src/packages/SPECS/
wget https://raw.github.com/marguerite/opensuse-spotify-installer/master/spotify.spec -O spotify.spec

# download source deb
cd ../SOURCES/

echo -e "\033[38;5;148mIf you already have spotify deb, please press 'ctrl + c',
put it under your home, and restart this script.(ignore if it's already done.)
or else we'll download it (may take a long time).\033[39m"

sleep 5

echo -e "\033[38;5;148mDownloading...\033[39m"
	
test -e /home/$NORMAL_USER/spotify-client_${SPOTIFY_VERSION}_$SPOTIFY_ARCH.deb && cp -r /home/$NORMAL_USER/spotify-client_${SPOTIFY_VERSION}_$SPOTIFY_ARCH.deb ./ || wget -c http://repository.spotify.com/pool/non-free/s/spotify/spotify-client_${SPOTIFY_VERSION}_$SPOTIFY_ARCH.deb

# build

echo -e "\033[38;5;148mBuilding...\033[39m"

cd ../SPECS/
rpmbuild -ba spotify.spec

echo -e "\033[38;5;148mBuild done! Cleaning...\033[39m"

# clean

## copy generated rpm

cp -r ../RPMS/$RPM_ARCH/*.rpm /home/$NORMAL_USER/
     
## real clean
rm -rf /usr/src/packages/SOURCES/spotify-*.deb
rm -rf /usr/src/packages/BUILD/spotify-*
rm -rf /usr/src/packages/BUILDROOT/*
rm -rf /usr/src/packages/RPM/$RPM_ARCH/spotify-*.rpm
rm -rf /usr/src/packages/SRPM/spotify-*.rpm
rm -rf /usr/src/packages/SPECS/spotify.spec

# install

## dependencies

echo -e "\033[38;5;148mResolving dependencies...\033[39m"

! [ `rpm -qa mozilla-nss` ] && zypper --no-refresh install mozilla-nss
! [ `rpm -qa mozilla-nspr` ] && zypper --no-refresh install mozilla-nspr
! [ `rpm -qa libopenssl1_0_0` ] && zypper --no-refresh install libopenssl1_0_0

echo -e "\033[38;5;148mInstalling...\033[39m"

rpm -ivh --force --nodeps /home/$NORMAL_USER/spotify-*.rpm

echo -e "\033[38;5;148mCongrats! Installation finished.
We put the generated RPM under your home.
Next time you can use 'sudo rpm -ivh --force --nodeps spotify-*.rpm' or
'sudo zypper --no-refresh install --force-resolution' to install it.\033[39m"

# quit

echo -e "\033[38;5;148mQuitting...\033[39m"

exit 0

