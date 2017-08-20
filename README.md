# VPN Access Point Setup

This script is was developed on a fresh install of Raspbian on a Raspberry Pi 2B.

## Tested Working
* Raspberry Pi
  - Raspbian

## Tested Wireless Adapters

### Working
* Alfa AWUS036NEH

### Not Working


## Setup

This setup assumes that the VPN client app is Openvpn, using *.ovpn files from Private Internet Access.
You must have an active PIA account and configure the script with your credentials 

1. Create a file called `ssh` on the boot partition of the Pi's SD card from your laptop. Place it
   in the Pi.
1. Boot your Pi with Ethernet and WiFi adapter plugged in. Make sure your computer is on the same network.
1. SSH in to the Pi. I used `nmap --open -p 22 192.168.1.1/24` to find the IP.

    ~~~bash.prettyprint
    # default password is raspberry
    ssh -l pi 192.168.1.200
    ~~~

1. CHANGE THE PASSWORD! 

    ~~~bash.prettyprint
    sudo passwd pi
    ~~~


1. Become root 

    ~~~bash
    sudo su
    cd /root
    ~~~

1. Download the setup script and run it as root. (Walkthrough of the script at the end of the post)
    
    ~~~bash
    # download
    wget https://raw.githubusercontent.com/audibleblink/vpn_access_point/master/setup.sh

    # read and configure it
    $EDITOR setup.sh

    # run it
    bash setup.sh
    ~~~

1. Reboot


If everything went well, when the Pi boots back up, there should be a new WiFi network in the area.
Log into it and visit https://www.privateinternetaccess.com/. You should say this happy little
green text near the top of the page.
