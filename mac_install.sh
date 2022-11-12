#!/bin/bash

echo ""
echo "##############################################################"
echo "# Starting Otter installation"
echo "############################################################"
echo ""

# Check for Homebrew, install if we don't have it
if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update homebrew recipes
brew update

# Install socat for relay between otter docker container and xquartz x11
echo "Installing socat..."
brew install socat

# Install xquartz x11
echo "Installing xquartz..."
brew install xquartz

echo 'Note: System requires reboot for xquartz to work as expected after fresh installation.'