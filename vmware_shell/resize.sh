#!/bin/bash

#创建并挂载/data
# mkdir -p /data
# mkfs.ext4 -F /dev/sdb
# uuid=`blkid|grep '/dev/sdb'|awk -F '"' '{print $2}'`
# echo "UUID=$uuid	/data	ext4	defaults	1	2" >> /etc/fstab
# mount -a

#扩容/data
umount /data
e2fsck -f /dev/sdb
resize2fs /dev/sdb
mount -a
echo "resize ok"