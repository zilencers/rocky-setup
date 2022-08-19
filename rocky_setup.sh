#!/bin/bash

declare -A packages
packages[git]='-y'
packages[podman]='-y'
packages[cockpit]='-y'
packages[cockpit-podman]='-y'
packages[wpa_supplicant]='-y'
packages[hostapd]='-y'
packages[nano]='-y'
packages[dkms]='--enablerepo="epel"'

# Updating the system
echo "Running system upgrade..."

if [ ! -f UPGRADE ]; then
    sudo dnf -y upgrade
    touch UPGRADE

    echo ""
    echo "--------------- Upgrade Complete ------------------"
    echo "A reboot is recommended. You can re-run this script"
    echo "after the reboot is complete."
    printf "Reboot now? (y/N) "
    read choice

    if [ $choice == 'y' ]; then
        sudo reboot
    fi
fi

# Add Repositories
echo "Adding EPEL Repository..."
sudo dnf -y install epel-release

# Install Packages
for key in "${!packages[@]}"; do
    echo "Installing Package: " $key
    sudo dnf ${packages[$key]} install $key 
done

# Enable Cockpit
sudo systemctl enable --now cockpit.socket

# Start Podman user service
systemctl start --user podman

# Install Wireless Drivers
echo "Installing Rtl88x2bu wireless drivers"
git clone "https://github.com/RinCat/RTL88x2BU-Linux-Driver.git" /usr/src/rtl88x2bu-git
sed -i 's/PACKAGE_VERSION="@PKGVER@"/PACKAGE_VERSION="git"/g' /usr/src/rtl88x2bu-git/dkms.conf
sudo dkms add -m rtl88x2bu -v git
sudo dkms autoinstall

