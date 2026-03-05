#!/bin/bash
for i in {1800..1}; do printf "\r倒计时: %02d:%02d:%02d" $((i/180000)) $(((i%1800)/60)) $((i%60)); sleep 1; done; echo -e "\n时间到！"
	#rm -f /mnt/custom.tar.gz
	#echo > nohup.out
	cd /data1/packer-maas/scripts/
	bash /data1/packer-maas/scripts/test

