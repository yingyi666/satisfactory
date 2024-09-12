#!/bin/bash

#BEGIN##############################
#BEGIN###函数和相关变量定义#########
#BEGIN##############################

# 1: debian
# 2: ubuntu
# 3: centos
# 4: arch linux
# 5: gentoo
# 6: opensuse
# 7: deepin
# 0: other linux
os=-1

# 检查是否 root
check_if_root() {
    if [ "$(id -u)" -eq 0 ]; then
        is_root=1
        echo -e "请勿使用 \033[31mroot\033[0m 账户运行该脚本，这并不安全！"
        exit 1
    else
        is_root=0
    fi
}

# check os
check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            debian)
                os=1
                ;;
            ubuntu)
                os=2
                ;;
            centos)
                os=3
                ;;
            arch)
                os=4
                ;;
            gentoo)
                os=5
                ;;
            opensuse*)
                os=6
                ;;
            deepin)
                os=7
                ;;
        esac
    else
        os=0
    fi
}

# 检查 sudo
check_sudo_installed() {
    if command -v sudo > /dev/null 2>&1; then
        is_there_sudo=1
    else
        is_there_sudo=0
        echo -e "未发现必须组件：\033[32msudo\033[0m"
        exit 1
    fi
}

# 检查 wget
check_wget_installed() {
    if command -v wget >/dev/null 2>&1; then
        is_there_wget=1
    else
        is_there_wget=0
    fi
}

# 检查 bc 是否安装
check_bc_installed() {
    if command -v bc >/dev/null 2>&1; then
        is_there_bc=1
    else
        is_there_bc=0
    fi
}

get_system_info() {
    # 获取物理内存大小并转换为MB
    mem_size_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_size_mb=$((mem_size_kb / 1024))
    
    # 获取虚拟内存大小并转换为MB
    swap_size_kb=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    swap_size_mb=$((swap_size_kb / 1024))
    
    # 获取CPU核数
    cpu_cores=$(nproc)
    
    # 获取本机的公网IP地址（使用wget）
    public_ip=$(wget -qO- http://ipecho.net/plain)
}

#END################################
#END#####函数和相关变量定义#########
#END################################


check_if_root

# 判别 linux 发行版
check_os

# 输出当前的 linux 发行版信息
echo -e "当前 Linux 发行版为：\033[32m${ID}\033[0m"

# 判别是否安装了 sudo
check_sudo_installed

# 判别是否安装了 wget
check_wget_installed

# 判别是否安装了 bc
check_bc_installed

