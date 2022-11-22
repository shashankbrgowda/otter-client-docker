#!/bin/bash

xhost +SI:localuser:$USER

# Pull the latest tagged image
docker pull shashankbrgowda/otter-client-docker:latest

docker run -ti --rm -e DISPLAY=$DISPLAY \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v $HOME/.otter/:/root/.otter/ \
	-v /var/tmp/otter_$USER/:/var/tmp/otter_root/ \
	shashankbrgowda/otter-client-docker:latest
