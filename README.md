# VPN Access Point Setup

This script was developed on a fresh install of Raspbian on a Raspberry Pi 2B.
When run on a fresh installation of Raspbian, it creates all the necessary files needed to start a
VPN tunnel on boot, create a hotspot, and forward AP client traffic through the VPN

## Verified Working Platforms
* Raspberry Pi 2B
  - [X] Raspbian

* Raspberry Pi 3
  - [X] Raspbian

## Verified Working Wireless Adapters
- [X] Alfa AWUS036NEH


## Setup

__A word about DNS leakage:__ Always check http://dnsleak.com/ for DNS leakage after connecting to
the Pi. I can't account for client/router settings to which the Pi will be connecting.

This setup assumes that the VPN client app is Openvpn, using *.ovpn files from Private Internet Access.
You must have an active PIA account and configure the script with your credentials 

1. Create a file called `ssh` on the boot partition of the Pi's SD card from your laptop. Place it
   in the Pi. Sometime in 2016, SSH was switched off by default on Raspbian unless this file exists.
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
Log into it and visit https://www.privateinternetaccess.com/. You should see green text near the top
that says you're protected.
