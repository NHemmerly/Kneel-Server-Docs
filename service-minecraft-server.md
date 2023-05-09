# Minecraft Server

*Everybody loves minecraft!* My self-hosted Minecraft server was the first service I built on my home server.  

## Overview

Because I'm using the Proxmox hypervisor, I decided to run the Minecraft server out of a virtual machine. Creating a game server is a great way to get the hang of home server fundamentals. The skills I've learned thus far from running my Minecraft server are listed below:

  - Creating and configuring linux virtual machines
    - This involves:
      - Basic network configuration (setting static ip, DNS, DHCP)
      - Installing, updating, and upgrading required packages
      - Creating and administering users, groups, and permissions
      - Setting up SSH remote connections
  - Port forwarding to allow internet connections
  - Creating a Dynamic DNS hostname in order to:
    1. Hide my public IPv4 address
    2. Prevent having to share my public IPv4 address at the end of every lease period
  - Using systemd services
    - Running the Minecraft server as a systemd service
    - Automating server restarts to prevent slowdowns
    - Automating server backups in the event of data corruption or griefing
  - Basic customer service skills
    - Helping my friends connect to the server 
    - Listening to what server tenants would like to see in the server administration-wise
     
## The Virtual Machine

I decided to run my Minecraft server using a virtual machine in the Proxmox hypervisor. The specs of the virtual machine are as follows:

  - Operating system:
    - Ubuntu Server 22.04
  - Two CPU Cores
    - The server would likely run just fine with one core
  - 4 GB RAM
  - 40 GB virtual disk

### Network Configuration

Configuring my VM's network settings felt fairly straightforward. I first configured my router to reserve a specific IP address for my virtual machine, and then I configured network settings within the Ubuntu operating system.

Navigating to netplan directory:

    cd /etc/netplan

Within my netplan directory there was only one file by default, the '00-installer-config.yaml' file. The '00-installer-config.yaml' file needed to be edited to reflect my desired network settings. To edit a text file as a non-root user, issue the command: 

    sudo nano /etc/netplan/00-installer-config.yaml

My finished config file:

    network:
      ethernets:
        ens18:
          dhcp4: no
            addresses:
              - 192.168.0.21/24
            routes:
              - to: default
                via: 192.168.0.1
            nameservers:
              addresses: [1.1.1.1, 1.0.0.1]
      version: 2

Since I am using a static IP address, DHCP servers are not required. DHCP servers can be turned off with `dhcp4: no`.
The information listed under `addresses` is the static IP address I assigned to my VM. The information shown under `routes` is required for showing the network's default gateway. Finally, the `addresses` listed under `nameservers` show my desired DNS servers. 

`ens18` is the name of the network adapter seen by my VM

After all settings are configured properly, they can be put into effect by issuing the command:

    sudo netplan apply

#### Port Forward

In order for a server to be accessible over the internet, the port used by the server needs to be exposed to the internet. Port forwarding allows a specified port on a local network to be accessible to others over an internet connection.

For me, all I needed to do to port forward my server was to log into my router's settings through a web browser and add a rule to the port forwarding settings. I added the static IP address I set for my VMm, as well as the port used by Minecraft servers, which is `25565` by default.

#### Dynamic DNS

In order to hide my public IP address from users on the server, I had to configure a dynamic DNS hostname. I used the website [dynu](https://www.dynu.com/en-US/) to setup my hostname. Dynu is a free service, however it does require a user account for using their hostnames. Setting up a hostname with dynu is fairly straightforward, however setting up automatic public IP updates can be a little tricky. 

The link [Dynu Update Client](https://www.dynu.com/DynamicDNS/IPUpdateClient/Linux) is what I used to setup IP updates. A chrome extension is also available to provide the same service. 

## The Minecraft Server

### PaperMC

Onto more exciting things! I used PaperMC as my server jar file. PaperMC is a third-party open-source Minecraft server project. This is my first Minecraft server, so I can't go into the nitty-gritty of running a PaperMC server versus another server setup. Here is a link [PaperMC](https://papermc.io/) for more info about PaperMC.

### Setup 

I used this [link](https://www.shells.com/l/en-US/tutorial/0-A-Guide-to-Installing-a-Minecraft-Server-on-Linux-Ubuntu) for my initial setup, plugging in some of my own settings where I saw fit. 

A prerequisite for running a minecraft server is installing the Java Runtime Environment. The most recent JRE can be installed on Ubuntu linux with:

    sudo apt update

and

    sudo apt install default-jdk

I started my server setup first by creating a `minecraft` user on my VM. The minecraft user will only have permissions to read, write, and execute files relevant to running the minecraft server. Creating a low-level user for running the server increases security in the wider filesystem. A minecraft user can be created with:

    sudo useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft

The minecraft user should create files for all server files, but first we have to switch to the minecraft user with:

    sudo su minecraft

Then we can create directories for the server to use with: 

    mkdir -p ~/{backups,tools,server}

#### MCrcon

One tool that is useful for automating particular server functions is MCrcon. MCrcon is a tool that allows Minecraft console commands to be entered remotely. Installing MCrcon goes as follows:

    cd ~/tools && git clone https://github.com/Tiiffi/mcrcon.git

First, changing directory to the minecraft/tools directory, and cloning the mcrcon git directory.

    cd tools/mcrcon

Move into the mcrcon directory.

    gcc -std=gnu11 -pedantic -Wall -Wextra -O2 -s -o mcrcon mcrcon.c

Compile the mcrcon tool.

    ./mcrcon -h

And finally, test the tool. 

#### PaperMC Setup

Now it is time to download and configure the PaperMC server. The server file for 1.19.3 can be downloaded with:

    wget https://api.papermc.io/v2/projects/paper/versions/1.19.3/builds/446/downloads/paper-1.19.3-446.jar -P ~/server

The server file needs to run once in order to access the configuration files. Run the server with: 

    java -Xmx1024M -Xms1024M -jar {name-of-jar.jar} nogui 

Replacing the integers in `-Xmx1024M` and `-Xms1024M` with maximum usable RAM and minimum amount of RAM in MBs respectively. The console will ask you to agree to the end user license agreement (EULA), to agree with the EULA use:

    nano ~/server/eula.txt

And change `eula=false` to `eula=true` and save the file. Finally, edit server properties to your specifications by using:

    nano ~/server/server.properties

To enable rcon edit:
  - `rcon.port=25575` 
  - `rcon.password=strong-password`
  - `enable-rcon=true`

At this point the server can be run again with the `java` command used earlier and it will be fully functional! However running a Minecraft server like this is a little manual, and it can get tedious over time. 

#### systemd configuration

Ubuntu allows users to create their own 'background processes' using systemd. Running a 24/7 server makes running it as a background service almost essential! Root user privileges are required for making systemd services. Ubuntu stores systemd services in the `/etc/systemd/system` directory. In order to create a new systemd service, issue the command: 

    sudo nano /etc/systemd/system/minecraft.service

The setup I use for my minecraft service looks like:

    [Unit]
    Description=Minecraft Server
    After=network.target
    [Service]
    User=minecraft
    Nice=1
    SuccessExitStatus=0 1
    ProtectHome=true
    ProtectSystem=full
    PrivateDevices=true
    NoNewPrivileges=true
    WorkingDirectory=/opt/minecraft/server/paperMC
    ExecStart=/usr/bin/java -Xmx3G -Xms1G -jar paperMC-1.19.3-445.jar nogui
    ExecStop=/opt/minecraft/tools/mcrcon/mcrcon -H 127.0.0.1 -P {rcon-password} stop
    [Install]
    WantedBy=multi-user.target

After saving and exiting the file, it can be loaded as a service with:

    sudo systemctl daemon-reload

Enabled with:

    sudo systemctl enable minecraft.service

The status can be checked with:

    sudo systemctl status minecraft

Finally if everything goes according to plan, started with:

    sudo systemctl start minecraft

Try connecting to your new Minecraft server!

#### Server Restart Service

While the server does run perfectly fine as a systemd service, it will start to slow down the longer the server is online. The above minecraft.service will automatically restart itself with every system restart, which is one convenient way to keep everything fast. However, manually restarting a VM or PC doesn't really work if I need to be away from home for an extended period and I still want to keep the server running smoothly for anybody that might join. In comes systemd *timers*. Timers are a useful scheduling tool in systemd that work similarly to the older crontab style of scheduling. First another *oneshot* service needs to be created to stop the server. Here is what mine looks like:

    [Unit]
    Description=Restarts the Minecraft Service

    [Service]
    Type=oneshot
    ExecStart=/usr/bin/systemctl restart minecraft.service

    [Install]
    WantedBy=multi-user.target

After creating and saving the above service, again run:

    sudo systemctl daemon-reload

Enable, and start the service to test it (seen in previous section). If everything is correct, the server should stop and restart itself. 

#### Timers

As mentioned earlier, timers can schedule restarts of a Minecraft service. My timer service looks like this:

    [Unit]
    Description=Run Minecraft reset every 8 hours

    [Timer]
    Unit=minecraft-restart.service
    OnCalendar=*-*-* 3,11,19:00:00
    Persistent=true

    [Install]
    WantedBy=timers.target

After enabling the timer, the server should restart itself every 8 hours (at 3:00AM, 11:00AM, and 7:00PM).

#### Backup Service

The backup service I created requires the use of [tar](https://www.baeldung.com/linux/tar-archive-without-directory-structure#:~:text=1.-,Overview,directory%20structure%20of%20archived%20files.). My backup service starts just like any systemd service, with a unit file. 

    [Unit]
    Description=Automate minecraft server backup with tar
    After=minecraft.service

    [Service]
    User=minecraft
    Type=oneshot
    Nice=2
    SuccessExitStatus=0 1
    ProtectHome=true
    ProtectSystem=full
    NoNewPrivileges=true
    WorkingDirectory=/opt/minecraft/backups
    ExecStart=/opt/minecraft/tools/tar-script.sh
    ExecStop=/opt/minecraft/tools/mcrcon/mcrcon -H 127.0.0.1 -P 25575 -p {rcon.password} "say Server Backup Finished!"

    [Install]
    WantedBy=multi-user.target

Note the `ExecStop` line! Messages can be sent to the minecraft server through the MCrcon tool I installed earlier. This service can run manually with:

    sudo systemctl start minecraft-backup

I wrote a custom script to create tar files, the tar script is shown here:

    #!/bin/bash

    DATE=$(date "+%m.%d.%Y-%H:%M:%S")

    tar -cvf /opt/minecraft/backups/minecraft-backup-$DATE.tar /opt/minecraft/server/paperMC

    cd /opt/minecraft/backups

    du -sh

The service can be automated to run ten minutes after every restart with the following timer unit:

    [Unit]
    Description=Run minecraft backup following server resets

    [Timer]
    Unit=minecraft-backup.service
    OnCalender=*-*-* 3,11,19:10:00
    Persistent=true

    [Install]
    WantedBy=timers.target

The basic service for my minecraft server are essentially complete!

## List of Plugins

 - [Brewery](https://dev.bukkit.org/projects/brewery#:~:text=Brewery%20is%20a%20Plugin%20for,%2C%20...%2C%201.8)
 - [SmoothTimber](https://www.spigotmc.org/resources/smoothtimber.39965/)
 - [MCMMO](https://wiki.mcmmo.org/)

