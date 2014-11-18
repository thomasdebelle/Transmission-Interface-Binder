#!/bin/bash
interfaceIP=$1;

echo "Writing New IP: $interfaceIP"
defaults write ~/Library/Preferences/org.m0k.transmission BindAddressIPv4 "$interfaceIP"