#!/bin/bash
#安装ELRepo
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

#安装lt内核，版本:5.4.240
yum -y  --enablerepo=elrepo-kernel install "kernel-uname-r == 5.4.240-1.el7.elrepo.x86_64"

#启用5.4.240版本内核
egrep ^menuentry /etc/grub2.cfg \
| cut -f 2 -d \' \
| grep -n '5.4.240-1.el7' \
| cut -b 1 \
| awk -F: '{print $1-1}' \
| xargs grub2-set-default

#设置启用bbr脚本并设置自启动
mkdir -p /root/bbr/logs
mkdir -p /root/bbr/bin
touch /root/bbr/bin/enable_bbr.sh && cat << 'EOF' > /root/bbr/bin/enable_bbr.sh
#!/bin/bash

#每次启动覆盖日志即可
touch /root/bbr/logs/info.log

correct_version="5.4.240-1.el7.elrepo.x86_64"
current_version=$(uname -r)

if [[ ${current_version} != ${correct_version} ]]; then
    echo "版本不匹配，终止" >> /root/bbr/logs/info.log
    #未安装指定版本内核，不返回错误码
    exit 0
else
    echo "版本匹配，初始化bbr" >> /root/bbr/logs/info.log
    correct_flag="tcp_bbr"
    current_flag=$(lsmod | grep bbr | awk "{print $1}")
    if [[ ${current_flag} =~ ${correct_flag} ]]; then
        echo "bbr已启动" >> /root/bbr/logs/info.log
    else
        echo "bbr未启动，初始化bbr" >> /root/bbr/logs/info.log
        echo "net.core.default_qdisc=fq" | tee -a /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" |  tee -a /etc/sysctl.conf
        sysctl -p
        lsmod_info=`lsmod | grep bbr`
        echo "lsmod_info : ${lsmod_info}" >> /root/bbr/logs/info.log
        #bbr初始化完成后移出启动项
        sed -i '/enable_bbr/d' /etc/rc.d/rc.local
    fi
fi
EOF
chmod +x /root/bbr/bin/enable_bbr.sh

echo '/root/bbr/bin/enable_bbr.sh' >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
systemctl enable rc-local.service

echo "Installation completed! execute reboot..."

#重启
reboot