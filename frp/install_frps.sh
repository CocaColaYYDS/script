#!/bin/bash
wget https://github.com/fatedier/frp/releases/download/v0.48.0/frp_0.48.0_linux_amd64.tar.gz
tar -zxvf frp_0.48.0_linux_amd64.tar.gz
mv tar -zxvf frp_0.48.0_linux_amd64/ /root/frp
cat << 'EOF' > /root/frp/frps.ini
#客户端和frp服务器连接的端口
bind_port = 7000
#仪表盘端口（网页端可视化页面）
dashboard_port = 7500
#访问仪表盘的用户名和密码
dashboard_user = root
dashboard_pwd = 123456
EOF
yum -y install systemd
touch /etc/systemd/system/frps.service && cat << 'EOF' > /etc/systemd/system/frps.service
[Unit]
# 服务名称，可自定义
Description = frp server
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
# 启动frps的命令，需修改为您的frps的安装路径
ExecStart = /root/frp/frps -c /root/frp/frps.ini

[Install]
WantedBy = multi-user.target
EOF
systemctl enable frps
reboot