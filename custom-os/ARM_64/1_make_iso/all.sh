#!/bin/bash
#gpg --full-generate-key
#gpg --list-secret-keys --keyid-format Long
###解压make maas镜像的packer包到/data1下######
#tar -zvxf /mnt/custom-os/make-packer.tar.gz -C /
#####安装kvm及packer相关包#####
apt -y install libnbd-bin nbdkit pigz packer fuse2fs cloud-image-utils ovmf curtin unzip lrzsz ipmitool build-essential 
apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
cp /mnt/custom-os/ARM_64/2_make_packer_tar/packer /usr/bin/packer
gpg --batch --generate-key /mnt/custom-os/ARM_64/1_make_iso/key_config.txt
apt -y install ansible sshpass xorriso
mkdir -p /etc/ansible/;cp /mnt/custom-os/x86_64/config/ansible.cfg /etc/ansible/ansible.cfg
timedatectl set-timezone Asia/Shanghai
wget -O /mnt/custom-os/ARM_64/ubuntu-24.04.3-live-server-arm64.iso http://10.10.249.70:8081/ubuntu-24.04.3-live-server-arm64.iso
key=`gpg --list-secret-keys --keyid-format Long|grep sec|tail -n1|cut -d/ -f2|cut -d' ' -f1`
mkdir -p /mnt/custom-os/ARM_64/iso /mnt/custom-os/ARM_64/iso-mount /mnt/custom-os/ARM_64/iso-ubuntu
mount -o loop /mnt/custom-os/ARM_64/ubuntu-24.04.3-live-server-arm64.iso /mnt/custom-os/ARM_64/iso-mount
cp -a /mnt/custom-os/ARM_64/iso-mount/. /mnt/custom-os/ARM_64/iso-ubuntu/
umount /mnt/custom-os/ARM_64/iso-mount
sed -i 's/-30/-10/g' /etc/grub.d/00_header
sed -i 's/^GRUB_TIMEOUT_STYLE=hidden$/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub;sed -i 's/^GRUB_TIMEOUT=0$/GRUB_TIMEOUT=10/' /etc/default/grub
update-grub

rm -f /mnt/custom-os/ARM_64/noble-arm64.iso;rm -f /mnt/custom-os/ARM_64/iso/filesystem.squashfs
mksquashfs / /mnt/custom-os/ARM_64/iso/filesystem.squashfs -e /mnt/* /proc/ /dev/ /sys/* /tmp/* /run/* /var/log/* /data1/ /data/ /cdrom  /gpfs /gpfs01 /etc/netplan/* /etc/cloud/cloud.cfg.d/* /var/snap/* /mnt.bak/ /home/ubuntu/bak/ /root/packer-maas/ /root/maas-3.5/ /root/maas-3.6/ /root/go/ /swap.img /root/go/ /root/maas-snap-offline-amd.tar.gz 
cp /mnt/custom-os/ARM_64/iso/filesystem.squashfs /mnt/custom-os/ARM_64/iso-ubuntu/casper/ubuntu-server-minimal.ubuntu-server.squashfs

gpg --batch --yes --pinentry-mode loopback --default-key $key \
	 --passphrase "12345678" \
	 --output /mnt/custom-os/ARM_64/1_make_iso/ubuntu-server-minimal.ubuntu-server.squashfs.gpg \
	 --detach-sign /mnt/custom-os/ARM_64/iso-ubuntu/casper/ubuntu-server-minimal.ubuntu-server.squashfs
cp /mnt/custom-os/ARM_64/1_make_iso/ubuntu-server-minimal.ubuntu-server.squashfs.gpg /mnt/custom-os/ARM_64/iso-ubuntu/casper
cd /mnt/custom-os/ARM_64/iso-ubuntu/casper/
gpg --verify ubuntu-server-minimal.ubuntu-server.squashfs.gpg \
	    ubuntu-server-minimal.ubuntu-server.squashfs
	
bash /mnt/custom-os/ARM_64/1_make_iso/update.sh
cd /mnt/custom-os/ARM_64/iso-ubuntu
find -type f -print0 | sudo xargs -0 md5sum | grep -v ./isolinux/ | grep -v ./md5sum.txt | sudo tee md5sum.txt>/dev/null
dd if=/mnt/ubuntu-24.04.3-live-server-arm64.iso \
  of=/mnt/iso-ubuntu/boot/grub/efi.img \
  bs=2048 \
  skip=1462072 \
  count=$((11456*512/2048))
xorriso -as mkisofs -joliet-long   -rock -r -J   -iso-level 3 -volid 'Ubuntu-arm64'  -e boot/grub/efi.img   -no-emul-boot   -isohybrid-gpt-basdat   -o "/data1/packer-maas/ubuntu/packer_cache/noble-arm64.iso"   .


###上传镜像到maas
#mv /data1/packer-maas/ubuntu/custom-ubuntu.tar.gz /home/ubuntu/
#cd /home/ubuntu/
#maas admin boot-resources create \
#name='ubuntu/Ubuntu-custom-hgh' \
#title='Ubuntu-custom-hgh' \
#architecture='arm64/generic' \
#filetype='tgz' \
#content@=custom-ubuntu.tar.gz

