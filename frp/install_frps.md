# 0.以root执行，pwd=/root

# 1.下载指定版本的frp安装包
```shell
wget https://github.com/fatedier/frp/releases/download/v0.48.0/frp_0.48.0_darwin_arm64.tar.gz
```

# 2.解压并重命名
```shell
tar -zxvf frp_0.48.0_darwin_arm64.tar.gz
```
```shell
mv tar -zxvf frp_0.48.0_darwin_arm64/ /root/frp
```

# 3.修改配置文件
```shell
cat << 'EOF' > /root/frp/frps.ini
#客户端和frp服务器连接的端口
bind_port = 7000
#仪表盘端口（网页端可视化页面）
dashboard_port = 7500
#访问仪表盘的用户名和密码
dashboard_user = root
dashboard_pwd = 123456
EOF
```

# 4.安装systemd（若未安装）
```shell
yum install systemd
```

# 5.设置开机自启
```shell
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
```

```shell
systemctl enable frps
```
# 6.重启并验证是否开机自启动
```shell
reboot
```
重启成功后
```shell
ps -ef|grep frp
```