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

# check if we have 'rpmbuild' package installed, if not then install it.

if rpm -qa rpm-build; then
	# already installed
else
	zypper install --no-refresh rpm-build # 'rpm-build' is in oss, so no need to refresh that long.
fi


# prepare for the build environment.

# download specfile from github
pushd /usr/src/package/SPECS/
wget https://raw.github.com/marguerite/opensuse-spotify-installer/master/spec/spotify.spec
popd

# download source deb
cd /usr/src/packages/SOURCES/

echo "Downloading..."
if [ `uname -m` == 'x86_64' ]; then
	wget http://repository.spotify.com/pool/non-free/s/spotify/spotify-client_0.8.4.103.g9cb177b.260-1_amd64.deb
else	
	wget http://repository.spotify.com/pool/non-free/s/spotify/spotify-client_0.8.4.103.g9cb177b.260-1_i386.deb
fi

# build

echo "Building..."

cd ../SPECS/
rpmbuild -ba spotify.spec

echo "Build done! Cleaning..."

# clean

## copy generated rpm

getNormalUser(){
        getppid() { grep PPid /proc/$1/status | sed 's/.*\t//' ; }
        ppid=`getppid $$`
        ppid=`getppid $ppid`
        ppid=`getppid $ppid`
        ls -lh /proc/$ppid/exe | cut -d ' ' -f3
}

$NORMAL_USER=`getNormalUser`

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

