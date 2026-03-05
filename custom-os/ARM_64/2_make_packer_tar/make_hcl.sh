#!/bin/bash
sum=`sha256sum /root/packer-maas/ubuntu/packer_cache/noble-amd64.iso|awk '{print$1}'`
sed -i "s/ISO_CHECKSUM_PLACEHOLDER/$sum/g" /root/packer-maas/ubuntu/ubuntu-flat.pkr.hcl
echo -e "\033[32m$sum\033[0m"

