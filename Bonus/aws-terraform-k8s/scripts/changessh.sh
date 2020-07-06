#! /bin/bash
systemctl disable firewalld >/dev/null 2>&1
systemctl stop firewalld
sed -i --follow-symlinks 's/Port 22/Port 443/' /etc/ssh/sshd_config
systemctl restart sshd.service