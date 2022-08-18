#!/bin/bash

declare -A packages
packages[git.x86_64]='-y'
packages[cockpit.x86_64]='-y'
packages[wpa_supplicant.x86_64]='-y'
packages[dkms.noarch]='--enablerepo="epel"'
packages[hostapd.x86_64]='-y'
packages[snapd.x86_64]='-y'
packages[vim-X11]='-y'
packages[kernel-devel]='-y'
packages[zfs]='-y'


# Add Repositories
echo "Adding EPEL Repository..."
dnf install epel-release

echo "\nAdding ZFS Repository..."
dnf install https://zfsonlinux.org/epel/zfs-release-2-2$(rpm --eval "%{dist}").noarch.rpm
gpg --import --import-options show-only /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

# Updating the system
dnf -y upgrade

# Install Packages
echo "\nInstalling Packages..."

for key in "${!packages[@]}"; do  
    if [ ! $(dnf list installed | grep -i $key) ] ; then
        dnf $key install ${packages[$key]}
    fi
done

# Enable SNAPD
systemctl enable snapd

# Start SNAPD
systemctl start snapd

# Install LXD
echo "\nInstalling LXD..."
snap install lxd

# Install Wireless Drivers
echo "\nInstalling Rtl88x2bu wireless drivers"
git clone "https://github.com/RinCat/RTL88x2BU-Linux-Driver.git" /usr/src/rtl88x2bu-git
sed -i 's/PACKAGE_VERSION="@PKGVER@"/PACKAGE_VERSION="git"/g' /usr/src/rtl88x2bu-git/dkms.conf
dkms add -m rtl88x2bu -v git
dkms autoinstall

