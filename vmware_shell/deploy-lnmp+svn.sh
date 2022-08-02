#!/bin/bash
#安装nginx
rpm -ql nginx
if [ $? -eq 0 ];then
	systemctl stop nginx
	yum -y remove nginx
fi
rpm -Uvh  http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
yum repolist
yum -y install nginx
systemctl restart nginx
systemctl enable nginx

#安装vsftpd
rpm -ql vsftpd
if [ $? -eq 0 ];then
        systemctl stop vsftpd
        yum -y remove vsftpd
fi
yum -y install vsftpd
cp -rf /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
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

#安装mariadb
rpm -ql mariadb
if [ $? -eq 0 ];then
	systemctl stop mariadb
	yum -y remove mariadb*
fi
yum -y install mariadb-server
systemctl start mariadb
systemctl enable mariadb
mysqladmin -uroot password 'xmz123'

#安装php
rpm -ql php
if [ $? -eq 0 ];then
        systemctl stop php-fpm
        yum -y remove php*
fi
yum -y install php php-fpm php-mysql
systemctl start php-fpm
systemctl enable php-fpm

#写php主页访问数据库，配置nginx主页访问php
cat <<! > /usr/share/nginx/html/index.php
<?php
header("Content-type:text/html;charset=utf-8");
\$conn = mysqli_connect('localhost','root','xmz123');
if(\$conn){
        echo "数据库连接成功！！";
}else{
        die("连接失败：".mysqli_connect_error());
}
?>
!
cat <<! > /usr/share/nginx/html/info.php
<?php
echo phpinfo();
?>
!
cp -f /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.baks
sed -i "33s/\/scripts/\$document_root/g" /etc/nginx/conf.d/default.conf
sed -i "30s/html/\/usr\/share\/nginx\/html/g" /etc/nginx/conf.d/default.conf
sed -i "9s/index.html/index.php index.html/g" /etc/nginx/conf.d/default.conf
sed -i "29,35s/#//g" /etc/nginx/conf.d/default.conf
systemctl restart nginx
echo "部署lnmp+vsftp已完成"
