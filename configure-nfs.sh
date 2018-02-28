#!/bin/sh

# Start services
systemctl start rpcidmapd.service
systemctl start rpcbind.service
systemctl start autofs.service

# Kill autofs pid and restart, because Linux
ps -ef | grep '/usr/sbin/automount' | awk '{print $2}' | xargs kill -9
service autofs start
