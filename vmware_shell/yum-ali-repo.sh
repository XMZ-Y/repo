cd /etc/yum.repos.d/
mv CentOS-Base.repo CentOS-Base.repo.bak
yum -y install wget
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo?spm=a2c6h.25603864.0.0.3d975969vgVeSX
yum clean all
yum repolist