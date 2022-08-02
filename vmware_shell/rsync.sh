#!/bin/bash
#安装rsync
#yum -y install rsync
#同步root下shell文件
for i in 12 20
do
	rsync -au --delete -e "ssh -p 1002 -o StrictHostKeyChecking=no" /root/shell 192.168.21.$i:/root/
done
echo "rsync ok"