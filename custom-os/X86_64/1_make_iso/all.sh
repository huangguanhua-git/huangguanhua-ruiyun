#!/bin/bash
#gpg --full-generate-key
#gpg --list-secret-keys --keyid-format Long
###解压make maas镜像的packer包到/data1下######
#tar -zvxf /mnt/custom-os/make-packer.tar.gz -C /
#####安装kvm及packer相关包#####
apt -y install libnbd-bin nbdkit pigz packer fuse2fs cloud-image-utils ovmf curtin unzip lrzsz ipmitool sshpass build-essential
apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
cp /mnt/custom-os/X86_64/2_make_packer_tar/packer /usr/bin/packer
gpg --batch --generate-key /mnt/custom-os/X86_64/1_make_iso/key_config.txt
apt -y install ansible sshpass xorriso
mkdir -p /etc/ansible/;cp /mnt/custom-os/X86_64/config/ansible.cfg /etc/ansible/ansible.cfg
timedatectl set-timezone Asia/Shanghai
scp 10.10.249.98:/data/custom-iso/ubuntu-22.04.5-live-server-amd64.iso /mnt/custom-os/X86_64/
key=`gpg --list-secret-keys --keyid-format Long|grep sec|tail -n1|cut -d/ -f2|cut -d' ' -f1`
mkdir -p /mnt/custom-os/X86_64/iso /mnt/custom-os/X86_64/iso-mount /mnt/custom-os/X86_64/iso-ubuntu
mount -o loop /mnt/custom-os/X86_64/ubuntu-22.04.5-live-server-amd64.iso /mnt/custom-os/X86_64/iso-mount
cp -a /mnt/custom-os/X86_64/iso-mount/.  /mnt/custom-os/X86_64/iso-ubuntu/
umount /mnt/custom-os/X86_64/iso-mount
sed -i 's/-30/-10/g' /etc/grub.d/00_header
sed -i 's/^GRUB_TIMEOUT_STYLE=hidden$/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub;sed -i 's/^GRUB_TIMEOUT=0$/GRUB_TIMEOUT=10/' /etc/default/grub
update-grub

rm -f /mnt/custom-os/X86_64/iso/filesystem.squashfs
mksquashfs / /mnt/custom-os/X86_64/iso/filesystem.squashfs -e /mnt/* /proc/ /dev/ /sys/* /tmp/* /run/* /var/log/* /data1/ /data/ /cdrom /home/gitlab-runner  /etc/netplan/* /etc/cloud/cloud.cfg.d/* /var/snap/* /mnt.bak/ /root/packer-maas/ /root/maas/ /root/maas-3.6/ /root/go/ /swap.img /root/.config/* /etc/systemd/system/clash.service /usr/local/bin/clash /root/clash/ /opt/* /root/parts/ /var/cache/ /root/snap/ /root/.cache 
cp /mnt/custom-os/X86_64/iso/filesystem.squashfs /mnt/custom-os/X86_64/iso-ubuntu/casper/ubuntu-server-minimal.ubuntu-server.squashfs

gpg --batch --yes --pinentry-mode loopback --default-key $key \
	 --passphrase "12345678" \
	 --output /mnt/custom-os/X86_64/1_make_iso/ubuntu-server-minimal.ubuntu-server.squashfs.gpg \
	 --detach-sign /mnt/custom-os/X86_64/iso-ubuntu/casper/ubuntu-server-minimal.ubuntu-server.squashfs
cp /mnt/custom-os/X86_64/1_make_iso/ubuntu-server-minimal.ubuntu-server.squashfs.gpg /mnt/custom-os/X86_64/iso-ubuntu/casper
cd /mnt/custom-os/X86_64/iso-ubuntu/casper/
#gpg --verify ubuntu-server-minimal.ubuntu-server.squashfs.gpg \
#	    ubuntu-server-minimal.ubuntu-server.squashfs
	
bash /mnt/custom-os/X86_64/1_make_iso/update.sh
cd /mnt/custom-os/X86_64/iso-ubuntu
find -type f -print0 | sudo xargs -0 md5sum | grep -v ./isolinux/ | grep -v ./md5sum.txt | sudo tee md5sum.txt>/dev/null
xorriso -as mkisofs \
-r -J -joliet-long -iso-level 3 \
-V 'Ubuntu-22.04.5 LTS amd64' \
--modification-date='2024091118464800' \
--grub2-mbr --interval:local_fs:0s-15s:zero_mbrpt,zero_gpt:'/mnt/custom-os/X86_64/ubuntu-22.04.5-live-server-amd64.iso' \
--protective-msdos-label \
-partition_cyl_align off \
-partition_offset 16 \
--mbr-force-bootable \
-append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b --interval:local_fs:4162948d-4173019d::'/mnt/custom-os/X86_64/ubuntu-22.04.5-live-server-amd64.iso' \
-appended_part_as_gpt \
-iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
-c '/boot.catalog' \
-b '/boot/grub/i386-pc/eltorito.img' \
-no-emul-boot \
-boot-load-size 4 \
-boot-info-table \
--grub2-boot-info \
-eltorito-alt-boot \
-e '--interval:appended_partition_2_start_1040737s_size_10072d:all::' \
-no-emul-boot \
-boot-load-size 10072 \
-o /root/packer-maas/ubuntu/packer_cache/jammy-amd64.iso \
.

