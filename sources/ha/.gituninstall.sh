#!/bin/bash

sudo apt-get remove --purge $(dpkg -l | grep $(echo +$(date -u +%y%m)) | awk '{print $2}' | xargs)
sudo apt-get --purge autoremove -y
