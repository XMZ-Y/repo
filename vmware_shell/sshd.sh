#!/bin/bash
set -e
port=22
#写入公钥到.ssh目录
mkdir -p /root/.ssh
cat <<EOF > /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAwTh8V3vp5W+cK8fS+8zn19IRSA7E+9Lg9WaIV+OSSHyx5JKYGTCUffz/fl/zqLfbNfm/7aZntdJbeRchuhvLDGdQ/ojE7HnnsZ/zMRU9NG9nN5vy0SOlBsyYUHmn5l71RJovvgNKJtRuvIq/5uDXol7vGfdpkr+ip8djiDcWAV6ynWRwc1X2sWHFeg+kWRW2FIXOwYTrL2/sWaWnrv+1RwFULfk+/h+w1pgX3umf1wIkr9hI4ULS5mdVqKZrtYFJmvUVEyVT7TT+40OSFWqfFJSI1tAg5vTHqp3qyWC+Wy5ZorynGhTFmj2hQrdT1R+6sx9ogHwhRmEzhhZPr/v/NQ== rsa 2048-061922
ssh-dss AAAAB3NzaC1kc3MAAACBAPVFCMe1agMyMwSIPTTr5xh4wYa1LJVMbIU0HvtcRXB+FvYgEqIqgHOZVolpVe1RFiqnET5GnYcFi5YV93uHBE6YpxGMrjg0EMt/bScS+nXyzJpbPqwWy0WHEbPJMZEHd6wMroRcOrdhAAqzczU6QnQffbIP0f/EXS4Ill/tFnOHAAAAFQDSeJvDGS+XItq0oKMg2ZHYrO9HPwAAAIAn9uBAhd3id5MybgdzkUXPUK2RVte/K9QLXx1s0iRrMYtd4A8znLyvcU0NOeyz/KFkynnnGW3GzpVjXLgl1w1a8ODC5qyN68cweQJ7Y+M2N014L3h9hx/gaownkvdbm7Oqk8XpRankXC7/vuwstsjN8Py8E+EKna5Qc60TNbtQRAAAAIADRzvsB6M+2HEJVwjmr1DTxwjhI+t66W1NuY8/NmxA7BWouIs7VaGB6qTsyo6muAHT+c+BWfVd9cJneRZSp9rtQeSBq3GFlsLBYocyz2Y8K8BHLpb7T+DxWbMV8Rajkx8gTsM3uiyOZeq4pqk6JZzK1jccjlMbGFOk/NGOi2lYkw==
EOF
#修改sshd配置
sed -i "s/#Port 22/Port ${port}/g" /etc/ssh/sshd_config
sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
#重启sshd
systemctl restart sshd
echo "修改sshd完成"