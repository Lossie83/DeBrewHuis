#!/bin/bash
DATE=$(date +%Y-%m-%d)
DEST="cloud:brew-backups/$DATE"

rclone sync /home/pi/brewlogs "$DEST/brewlogs"
rclone sync /home/pi/.node-red "$DEST/node-red" --include "flows.json" --include "flows_cred.json" --include "settings.js"
