#!/bin/bash

echo '等待镜像生成并开始压缩...'
start=$(date +%s)
timeout=3600  # 1小时超时

while true; do
  elapsed=$(($(date +%s)-start))
  
  # 检查是否超时
  if [ $elapsed -gt $timeout ]; then
    echo '等待超时，跳过加速压缩'
    break
  fi
  
  # 检查是否有压缩进程或特定文件存在
  gzip_count=$(sudo ps -ef | grep 'gzip --best' | grep -v grep | wc -l)
  
  # 检查 packer-flat 文件是否存在
  if [ -f /data1/packer-maas/ubuntu/output-flat/packer-flat ]; then
    file_exists=1
  else
    file_exists=0
  fi
  
  # 如果检测到压缩进程或文件存在，则开始加速压缩
  if [ $gzip_count -eq 1 ]; then
    echo '检测到压缩进程或镜像已生成，开始加速压缩'
    break
  else
    printf '\r等待时间: %02d分%02d秒' $((elapsed/60)) $((elapsed%60))
    sleep 5
  fi
done
