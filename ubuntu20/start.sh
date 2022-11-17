#!/bin/bash

read -p "Enter config.ini location (ex: /home/ebi/config.ini): " filepath

# Stop if any existing socat running for clean start
kill -9 $(ps -ef | grep 6000 | awk 'NR==1{print $2; exit}')

# Start socat - bridge between a network socket with a TCP listener on port 6000 (the 
# default port of the X window system) and the X window server (xquartz x11) on my OS X host
socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &

export DISPLAY=`hostname -I | cut -f1 -d' '`:0
xhost +

# Pull the latest tagged image
docker pull shashankbrgowda/otter-client-docker:latest

docker run -ti --rm -e DISPLAY=$DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v $filepath:/root/.otter/config.ini \
	-v $HOME/otter/:/root/.otter/ \
	-v $HOME/otter/sqlite/:/var/tmp/otter_root/ \
	shashankbrgowda/otter-client-docker:latest
