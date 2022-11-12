#!/bin/bash

read -p "Enter config.ini location (ex: /home/ebi/config.ini): " filepath

# Stop if any existing socat running for clean start
kill -9 $(lsof -n -i | grep 6000 | awk '{ print $2 }')

# Start socat - bridge between a network socket with a TCP listener on port 6000 (the 
# default port of the X window system) and the X window server (xquartz x11) on my OS X host
socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &

# Start xquartz x11
open -a Xquartz

# Allow connections from network clients
defaults write org.xquartz.X11.plist nolisten_tcp -bool false

export DISPLAY=`ipconfig getifaddr en0`:0
xhost +

docker pull shashankbrgowda/otter-client-docker:1.0.0

docker run -ti --rm -e DISPLAY=$DISPLAY \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v $filepath:/root/.otter/config.ini \
shashankbrgowda/otter-client-docker:1.0.0
