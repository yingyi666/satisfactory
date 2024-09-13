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

check_command_installed() {
    command_name="$1"
    if command -v "$command_name" >/dev/null 2>&1; then
        return 0  # 成功
    else
        return 1  # 失败
    fi
}

# 检查 sudo
check_sudo_installed() {
    if check_command_installed sudo; then
        is_there_sudo=1
    else
        is_there_sudo=0
        echo -e "未发现必须组件：\033[32msudo\033[0m"
        exit 1
    fi
}

# 检查 wget
check_wget_installed() {
    if check_command_installed wget; then
        is_there_wget=1
    else
        is_there_wget=0
    fi
}

# 检查 bc 是否安装
check_bc_installed() {
    if check_command_installed bc; then
        is_there_bc=1
    else
        is_there_bc=0
    fi
}

# 检查 awk 是否安装
check_awk_installed() {
    if check_command_installed awk; then
        is_there_awk=1
    else
        is_there_awk=0
    fi
}

# 检查 grep 是否安装
check_grep_installed() {
    if check_command_installed grep; then
        is_there_grep=1
    else
        is_there_grep=0
    fi
}

# 检查 nproc 是否安装
check_nproc_installed() {
    if check_command_installed nproc; then
        is_there_nproc=1
    else
        is_there_nproc=0
    fi
}

# 检查 fallocate 是否安装
check_fallocate_installed() {
    if check_command_installed fallocate; then
        is_there_fallocate=1
    else
        is_there_fallocate=0
    fi
}

# 获取系统信息
get_system_info() {
    # 获取物理内存大小并转换为MB
    mem_size_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_size_mb=$((mem_size_kb / 1024))
    
    # 获取虚拟内存大小并转换为MB
    swap_size_kb=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    swap_size_mb=$((swap_size_kb / 1024))
    
    # 获取CPU核数
    cpu_cores=$(grep -c ^processor /proc/cpuinfo)
    
    # 获取本机的公网IP地址（使用wget）
    public_ip=$(wget -qO- http://ipecho.net/plain)
}

deps_info() {
    echo "依赖检测："
    echo "sudo:      $( [ "$is_there_sudo" -eq 1 ] && echo "已安装" || echo "未安装" )"
    echo "wget:      $( [ "$is_there_wget" -eq 1 ] && echo "已安装" || echo "未安装" )"
    echo "bc:        $( [ "$is_there_bc" -eq 1 ] && echo "已安装" || echo "未安装" )"
    echo "awk:       $( [ "$is_there_awk" -eq 1 ] && echo "已安装" || echo "未安装" )"
    echo "grep:      $( [ "$is_there_grep" -eq 1 ] && echo "已安装" || echo "未安装" )"
    echo "fallocate: $( [ "$is_there_fallocate" -eq 1 ] && echo "已安装" || echo "未安装" )"
}

# 打印系统信息
print_sys_info() {
    echo -e "物理内存大小：${mem_size_mb}MB"
    echo -e "虚拟内存大小：${swap_size_mb}MB"
    echo -e "CPU 核数：${cpu_cores}"
    echo "本机的公网IP：${public_ip}"
}

# 安装缺失的依赖
# install_deps() {
#
# }

set_swapfile() {
    local swapfile_size=$1
    local swapfile_path=$2

    # 创建交换文件
    sudo fallocate -l ${swapfile_size}G ${swapfile_path}
    
    # 设置交换文件权限
    sudo chmod 600 ${swapfile_path}
    
    # 设置交换文件
    sudo mkswap ${swapfile_path}
    
    # 启用交换文件
    sudo swapon ${swapfile_path}
    
    # 将交换文件添加到 fstab
    echo "${swapfile_path} none swap sw 0 0" | sudo tee -a /etc/fstab > /dev/null
}

#END################################
#END#####函数和相关变量定义#########
#END################################

# 检查是否是 root 下运行，不应该 root 运行
check_if_root

# 判别 linux 发行版
check_os

# 输出当前的 linux 发行版信息
echo -e "当前 Linux 发行版为：\033[32m${ID}\033[0m"

# 检查依赖是否安装
check_sudo_installed
check_wget_installed
check_bc_installed
check_awk_installed
check_grep_installed
check_fallocate_installed

deps_info

# 检查系统信息
get_system_info

print_sys_info

