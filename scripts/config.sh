#!/usr/bin/sh
sudo systemctl start NetworkManager.service
sudo raspi-config
sudo systemctl stop NetworkManager.service
