#!/bin/bash
port=22
#写入公钥到.ssh目录
mkdir /root/.ssh 2> /dev/null
cat <<EOF > /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAwTh8V3vp5W+cK8fS+8zn19IRSA7E+9Lg9WaIV+OSSHyx5JKYGTCUffz/fl/zqLfbNfm/7aZntdJbeRchuhvLDGdQ/ojE7HnnsZ/zMRU9NG9nN5vy0SOlBsyYUHmn5l71RJovvgNKJtRuvIq/5uDXol7vGfdpkr+ip8djiDcWAV6ynWRwc1X2sWHFeg+kWRW2FIXOwYTrL2/sWaWnrv+1RwFULfk+/h+w1pgX3umf1wIkr9hI4ULS5mdVqKZrtYFJmvUVEyVT7TT+40OSFWqfFJSI1tAg5vTHqp3qyWC+Wy5ZorynGhTFmj2hQrdT1R+6sx9ogHwhRmEzhhZPr/v/NQ== rsa 2048-061922
EOF
#修改sshd配置
sed -i "s/#Port 22/Port $port/g" /etc/ssh/sshd_config
sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
#重启sshd
systemctl restart sshd
exit 0