# Networking

## Router Firmware

After tinkering around with my router for a couple of days I quickly realized that it didn't seem to include many of the features that I needed for managing a secure home network. I saw the need to change that.

While researching solutions I stumbled upon firmware upgrades, specifically [OpenWrt](https://openwrt.org/start) and [DD-WRT](https://dd-wrt.com/) (WRT standing for 'wireless router') that included compatibility with many of the most common home routers. After researching both OpenWrt and DD-WRT, I went with OpenWrt primarily because the documentation seemed more accessible and it was compatible with my *TP-Link Archer A7*.

The firmware upgrade process was simple and the in-depth process and download can be found [here](https://openwrt.org/toh/tp-link/archer_a7_v5). The latest version when I installed OpenWrt was *ver. 22.03.3*, so that's the version I used. 

  - After logging into my router's management UI, all I had to do was navigate to *Advanced > System Tools > Firmware Upgrade*.

  - Once on the Firmware upgrade page, I downloaded *Firmware OpenWrt Install* from the link above and browsed for the new file from the webUI. 

  - After confirming that I selected the correct file I initiated the firmware upgrade process. CAUTION: Firmware upgrades are very sensitive, powering off the router or changing its settings can render the router useless.

  - Once the install process was complete I restarted my router and I was able to log in to the new OpenWrt WebUI!

## Network Configuration

#### Network Diagram

![A crude drawing of my basic network layout](./images/Network-diagram-1.png "Network Diagram")

My basic network configuration consists of mostly wireless devices, and a few wired devices. The theory behind my network design is 

## Subnetting and VLANs