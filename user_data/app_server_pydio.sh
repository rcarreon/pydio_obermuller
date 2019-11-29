#!/bin/bash -ex
# Set Hostname

IPV4=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
HOSTNAME=$(echo epam-devops-xport-app-dev-$INSTANCE_ID)

if [ -f /etc/system-release ];then
   echo "Setting Hostname on Amazon System"
   hostname $HOSTNAME
   # Add fqdn to hosts file
cat<<EOF > /etc/hosts
# This file is automatically genreated by ec2 cloud init script
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
$IPV4 $HOSTNAME.$DOMAIN $HOSTNAME
::1         localhost6 localhost6.localdomain6
EOF
echo "HOSTNAME=epam-devops-xport-app-dev-$INSTANCE_ID" >> /etc/sysconfig/network
hostnamectl set-hostname $HOSTNAME
            

else
   echo "System not recognized!"
fi

cat<<EOF> /etc/yum.repos.d/MariaDB10.repo
# MariaDB 10.1 CentOS repository list - created 2016-01-18 09:58 UTC
# http://mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB  
baseurl = http://yum.mariadb.org/10.1/centos7-amd64  
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB  
gpgcheck=1  
EOF
rpm -Uvh http://dl.ajaxplorer.info/repos/pydio-release-1-1.noarch.rpm

#yum -y install epel-release yum-utils  
amazon-linux-extras install epel
yum -y install pydio mariadb-server mariadb  httpd.x86_64 php-mysql.x86_64 php-mbstring php-pdo php-xml php-gd php-opcache php-mysqlnd php-pecl-zip automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel
#
## TODO### 
#
cat<<EOF> /etc/httpd/conf.d/pydio.conf
Alias /pydio /usr/share/pydio
Alias /pydio_public /var/lib/pydio/public
<VirtualHost *:80>
    ServerName pydio.net
    DocumentRoot "/usr/share/pydio"
    ErrorLog /usr/share/pydio/logs/pydio_error.log
    CustomLog /usr/share/pydio/logs/pydio_access.log combined


    <Directory "/usr/share/pydio">
        Options FollowSymlinks
        AllowOverride None
        Require all granted
    </Directory>
    <Directory "/var/lib/pydio/public">
        AllowOverride Limit FileInfo
        Order allow,deny
        Allow from all
        php_value error_reporting 2
    </Directory>
</VirtualHost>
EOF
mkdir /usr/share/pydio/logs/ 

cd /home/ec2-user/ && wget https://static.wixstatic.com/media/04ab37_0e53282879604ecbbea9d4e8677fcbbc~mv2_d_2952_1478_s_2.png/v1/fill/w_354,h_172,al_c,q_80,usm_0.66_1.00_0.01/Obermoller%20Engineering%20Logo.webp

sed -i 's/post_max_size\ =\ 8M/post_max_size\ =\ 1024M/g' /etc/php.ini
sed -i 's/upload_max_filesize\ =\ 2M/upload_max_filesize\ =\ 1024M/g' /etc/php.ini
### OLD PYDIO ###

systemctl start mariadb  
systemctl enable mariadb.service  
systemctl restart httpd.service
systemctl enable httpd.service  
#usermod -a -G docker ec2-user
### MYSQL ### 
/usr/bin/mysqladmin -u root  password '${ROOT_PASS}'
cat<<EOF> /home/ec2-user/setup.sql
CREATE DATABASE pydiodb;
GRANT ALL ON pydiodb.* to 'pydiouser'@'localhost' IDENTIFIED BY '${PYDIO_PASS}';
FLUSH PRIVILEGES;
EOF
mysql -u root -p${ROOT_PASS} < /home/ec2-user/setup.sql
cp /home/ec2-user/Obermoller\ Engineering\ Logo.webp  /usr/share/pydio/plugins/gui.ajax/res/themes/orbit/images/LoginBoxLogo.png
setenforce 0 
