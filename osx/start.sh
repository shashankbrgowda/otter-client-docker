#!/bin/bash

if ! pgrep -x "socat" > /dev/null
then
    # Start socat - bridge between a network socket with a TCP listener on port 6000 (the 
	# default port of the X window system) and the X window server (xquartz x11) on my OS X host
	socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
fi

# Start xquartz x11
open -a Xquartz

# Allow connections from network clients
defaults write org.xquartz.X11.plist nolisten_tcp -bool false

export DISPLAY=`ipconfig getifaddr en0`:0

xhost +SI:localuser:$USER

# Pull the latest tagged image
docker pull shashankbrgowda/otter-client-docker:latest

docker run -ti --rm -e DISPLAY=$DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v $HOME/.otter/:/root/.otter/ \
	-v $HOME/otter_$USER/:/var/tmp/otter_root/ \
	shashankbrgowda/otter-client-docker:latest

# Kill socat if we are shutting down the last otter docker container
if [ $(docker ps -a | grep -ic "otter-client-docker") -eq "1" ]
then
	kill $(lsof -n -i | grep 6000 | awk '{ print $2 }')
fi
