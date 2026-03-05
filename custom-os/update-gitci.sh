#!/bin/bash

# 设置安全目录
#git config --global --add safe.directory /mnt/custom-os
#git config --global --add safe.directory "/home/gitlab-runner/builds/DnjbCy4u-/0/devops/custom-os"

# 如果第一个参数为1，则回退到上一个版本
if [ "$1" = "1" ]; then
    echo "正在回退到上一个版本..."
    git reset --hard HEAD~1
    GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git push -f origin main
    echo "已回退到上一个版本并强制推送到远程仓库"
    exit 0
fi

# 检查是否有未提交的更改
if ! git diff-index --quiet HEAD --; then
    echo "检测到未提交的更改"
    read -p "请输入更新说明（回车使用默认说明）: " commit_msg
    
    # 如果用户直接回车，使用默认说明
    if [ -z "$commit_msg" ]; then
        commit_msg="提交代码未做说明: $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    
    echo "正在提交更改..."
    git add .
    git commit -m "$commit_msg"
    echo "更改已提交"
fi

# 拉取更新
git pull --rebase origin main

# 设置远程仓库
git remote set-url origin git@git.sy.com:devops/custom-os.git

# 推送更改
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git push -u origin main

# 注释掉的用户配置
# git config --global user.email "huangguanhua@sytech.com"
# git config --global user.name "huangguanhua"
