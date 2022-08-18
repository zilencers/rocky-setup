#!/bin/bash

# Updating the system
dnf -y update

# Add EPEL Repository
echo "\nAdding EPEL Repository..."
if [ ! $(dnf repolist | grep -i epel) ] ; then
    dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
fi

# Install Packages
echo "\nInstalling Packages..."
declare -A packages
packages[git.x86_64]='-y'
packages[cockpit.x86_64]='-y'
packages[wpa_supplicant.x86_64]='-y'
packages[dkms.noarch]='--enablerepo="epel"'

for key in "${!packages[@]}"; do  
    if [ ! $(dnf list installed | grep -i $key) ] ; then
        dnf $key install ${packages[$key]}
    fi
done


# Install Wireless Drivers
echo "\nInstalling Rtl88x2bu wireless drivers"
git clone "https://github.com/RinCat/RTL88x2BU-Linux-Driver.git" /usr/src/rtl88x2bu-git
sed -i 's/PACKAGE_VERSION="@PKGVER@"/PACKAGE_VERSION="git"/g' /usr/src/rtl88x2bu-git/dkms.conf
dkms add -m rtl88x2bu -v git
dkms autoinstall

