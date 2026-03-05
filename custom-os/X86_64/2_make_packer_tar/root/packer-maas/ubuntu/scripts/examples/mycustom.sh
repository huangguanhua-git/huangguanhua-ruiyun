#!/bin/bash
apt -y install linux-image-5.15.0-126-generic linux-headers-5.15.0-126-generic
mkdir -p /curtin
echo -n "linux-bluefield=5.15.0-126-generic" > /curtin/CUSTOM_KERNEL
