#!/bin/bash -ex

cat<<EOF> /etc/yum.repos.d/MariaDB10.repo
# MariaDB 10.1 CentOS repository list - created 2016-01-18 09:58 UTC
# http://mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB  
baseurl = http://yum.mariadb.org/10.1/centos7-amd64  
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB  
gpgcheck=1  
EOF

yum install -y git python2 python3  gcc libstdc++-devel gcc-c++ curl-devel libxml2-devel openssl-devel mailcap httpd.x86_64 php.x86_64 php-common.x86_64 php-devel.x86_64 php-fpm.x86_64 php-ldap.x86_64 php-mbstring.x86_64 mariadb-server mariadb 
# Set Hostname
IPV4=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
INSTANCE_ID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`
HOSTNAME=`echo epam-devops-xport-app-dev-${INSTANCE_ID}`

if [ -f /etc/system-release ];then
   echo "Setting Hostname on Amazon System"
   hostname ${HOSTNAME}
   # Add fqdn to hosts file
cat<<EOF > /etc/hosts
# This file is automatically genreated by ec2 cloud init script
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
${IPV4} ${HOSTNAME}.${DOMAIN} ${HOSTNAME}
::1         localhost6 localhost6.localdomain6
EOF
echo "HOSTNAME=epam-devops-xport-app-dev-${INSTANCE_ID}" >> /etc/sysconfig/network
hostnamectl set-hostname $HOSTNAME
	

else
   echo "System not recognized!"
fi

cat<<EOF> /etc/httpd/conf.d/filerun.conf
<VirtualHost *:80>
    ServerName filerun.net
    DocumentRoot "/app/filerun"
    <Directory "/app/filerun/">
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF

#mkdir -p /app/filerun && chown ec2-user.ec2-user -R /app && cd /app/filerun  && curl -fsSL https://filebrowser.xyz/get.sh | bash
mkdir -p /app/filerun && chown ec2-user.ec2-user -R /app && cd /app/filerun

mv  /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/.welcome.conf
sed -i 's/index.html/index.html index.php/g' /etc/httpd/conf/httpd.conf

systemctl restart httpd.service
#usermod -a -G docker ec2-user

