#!/bin/bash
echo > /mnt/make.log
nohup bash -c 'bash all.sh ;cd /data1/packer-maas/ubuntu/;rm -f /data1/packer-maas/ubuntu/output-flat/packer-flat;make custom-ubuntu.tar.gz' > make.log 2>&1 &

# 后台计时并执行命令,
nohup bash -c '
start=$(date +%s); while true; do count=$(ps -ef | grep "gzip --best" | grep -v grep | wc -l); elapsed=$((`date +%s`-start)); if [ $count -eq 1 ]; then echo -e "\n镜像已生成，开始加速解压"; break; else printf "\r等待时间: %02d分%02d秒" $((elapsed/60)) $((elapsed%60)); sleep 5; fi; done
cd /data1/packer-maas/scripts/
bash /data1/packer-maas/scripts/test
    ' > time.log 2>&1 &

echo "计时已启动，PID: $!"





