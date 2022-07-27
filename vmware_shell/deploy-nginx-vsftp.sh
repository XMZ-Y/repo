#!/bin/bash
#安装nginx
rpm -Uvh  http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
yum repolist
yum -y install nginx
systemctl restart nginx
systemctl enable nginx

#安装vsftpd
yum -y install vsftpd
cat <<! > /etc/vsftpd/vsftpd.conf
listen=NO
listen_ipv6=YES
local_enable=YES
local_root=/usr/share/nginx
allow_writeable_chroot=YES
write_enable=YES
anonymous_enable=YES
no_anon_password=YES
anon_root=/usr/share/nginx
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
dirmessage_enable=YES
chroot_local_user=YES
connect_from_port_20=YES
pasv_enable=NO
!
chmod 777 /usr/share/nginx/html
systemctl restart vsftpd
systemctl enable vsftpd
exit 0