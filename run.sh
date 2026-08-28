#!/bin/bash

while true; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Unmounting drvs..."
    umount drvs 2>/dev/null

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Mounting //hyeon:001123@192.168.51.1/drvs -> drvs"
    if ! mount_smbfs //hyeon:001123@192.168.51.1/drvs drvs; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Mount failed, retrying in 1s..."
        sleep 3
        continue
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting ffmpeg-server.js..."
    node ffmpeg-server.js
    EXIT_CODE=$?
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ffmpeg-server.js exited with code $EXIT_CODE"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Unmounting drvs..."
    umount drvs 2>/dev/null
    sleep 0.1
done
