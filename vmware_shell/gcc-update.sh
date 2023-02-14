yum -y install centos-release-scl
 
yum -y install devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-binutils
 
scl enable devtoolset-9 bash
 
echo "source /opt/rh/devtoolset-9/enable" >> /etc/profile
