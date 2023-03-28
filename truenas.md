# TrueNas

My Minecraft server files were beginning to get quite big as I invited more people and installed more plugins. I only have a limited amount of storage on the virtual machine, and backups can get pretty large. I needed a solution for offloading some of the storage requirements of my Minecraft server as well as any additional services I add in the future. I came across TrueNas. 

## TrueNas Overview

[TrueNas Core](https://www.truenas.com/) is a "network-attached storage" operating system based on the [FreeBSD](https://www.freebsd.org/) operating system. TrueNAS uses ZFS (Zettabyte filesystem), which makes redundant storage easy to implement and scale. TrueNAS also comes with a webUI accessible by the system's local ip address by default.

## Implementation

I implemented TrueNAS on my home network as a virtual machine hosted by ProxMox. The specifications of my TrueNAS VM are listed below:

  - RAM: 8GB
  - CPU: 1 Core
  - Storage:
    - 32GB Virtual Disk (As a boot drive)
    - 2 X 2TB HDD (via hardware passthrough)
      - 1.8TB of usable storage when configured as a mirror
    
