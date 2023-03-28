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

## Creating Storage Pools

Once storage is successfully passed through to TrueNAS via Proxmox, creating a storage pool is only a few clicks away. On the TrueNAS webUI navigate to *Storage* > *Pools*. Click *Add*, select *Create new pool* > *Create Pool*, and then select the desired disks for creating a pool, as well as the desired format under the now-populated *Data VDevs* table. 

Because I only have two available disks, I selected *Mirror* to add redundancy to my storage at the expense of useable space. After naming my storage pool and clicking *Create*, my storage pool is complete!  

## Creating Network Shares 

Adding network shares is surprisingly easy through the TrueNAS webUI. I have several Windows, MacOS, and Linux machines on my home network so I wanted to create a share that is compatible with each one of those operating systems. SMB (server message block) works great across all of those operating systems, so that is the share I created. 

To create an SMB share navigate to *Sharing* > *Windows Shares (SMB)*. I selected the filepath for the dataset I created earlier, and I clicked on *Advanced Options* where I added the hosts I wanted to have access to the share. 

I was able to connect to my share easily through both Windows and Linux following the steps listed below: