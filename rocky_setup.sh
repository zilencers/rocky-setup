#!/bin/bash

declare -A packages
packages[git]='-y'
packages[cockpit]='-y'
packages[wpa_supplicant]='-y'
packages[dkms]='--enablerepo="epel"'
packages[hostapd]='-y'
packages[snapd]='-y'
packages[nano]='-y'
packages[kernel-devel]='-y'
packages[zfs]='-y'


# Updating the system
echo "Running system upgrade..."

dnf -y upgrade

echo ""
echo "--------------- Upgrade Complete ------------------"
echo "A reboot is recommended. You can re-run this script"
echo "after the reboot is complete."
printf "Reboot now? (y/N) "
read choice

if [ $choice == 'y' ]; then
    reboot
fi

# Add Repositories
echo "Adding EPEL Repository..."
dnf -y install epel-release

echo "Adding ZFS Repository..."
dnf -y install https://zfsonlinux.org/epel/zfs-release-2-2$(rpm --eval "%{dist}").noarch.rpm
gpg --import --import-options show-only /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

# Install Packages
for key in "${!packages[@]}"; do
    echo "Installing Package: " $key
    dnf ${packages[$key]} install $key 
done

# Enable SNAPD
systemctl enable snapd

# Start SNAPD
systemctl start snapd

# Install LXD
echo "Installing LXD..."
snap install lxd

# Install Wireless Drivers
echo "Installing Rtl88x2bu wireless drivers"
git clone "https://github.com/RinCat/RTL88x2BU-Linux-Driver.git" /usr/src/rtl88x2bu-git
sed -i 's/PACKAGE_VERSION="@PKGVER@"/PACKAGE_VERSION="git"/g' /usr/src/rtl88x2bu-git/dkms.conf
dkms add -m rtl88x2bu -v git
dkms autoinstall

