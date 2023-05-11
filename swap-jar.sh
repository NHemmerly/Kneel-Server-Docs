#!/bin/bash

cd ~

systemctl stop minecraft.service

mv /server/paperMC/minecraft*.jar /mnt/share/old-jar

cp /mnt/share/new-jar/minecraft*.jar /server/paperMC/

systemctl start minecraft.service