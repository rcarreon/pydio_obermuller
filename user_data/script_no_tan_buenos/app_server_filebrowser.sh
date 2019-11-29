#!/bin/bash -ex
yum remove fuse fuse-s3fs
yum install -y git docker python2 python3  gcc libstdc++-devel gcc-c++ curl-devel libxml2-devel openssl-devel mailcap httpd.x86_64 php.x86_64 php-common.x86_64 php-devel.x86_64 php-fpm.x86_64 php-ldap.x86_64 php-mbstring.x86_64 fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel 
#amazon-linux-extras install epel php7.3
#yum -y install mariadb-server mariadb  httpd.x86_64 php-mbstring php-pdo php-xml php-gd php-opcache php-mysqlnd php-pecl-zip automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel
# Set Hostname
IPV4=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
INSTANCE_ID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`
HOSTNAME=`echo epam-devops-xport-app-dev-$INSTANCE_ID`

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

cat<<EOF> /etc/httpd/conf.d/ajaxplorer.conf
<VirtualHost *:80>
    ServerName rob-ajax.net
    DocumentRoot "/app/ajaxexplorer"
    <Directory "/app/ajaxexplorer/">
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF

mv  /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/.welcome.conf
mkdir -p /app/filebrowser && chown ec2-user.ec2-user -R /app && cd /app/filebrowser && curl -fsSL https://filebrowser.xyz/get.sh | bash
#mv  /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/.welcome.conf
sed -i 's/index.html/index.html index.php/g' /etc/httpd/conf/httpd.conf

systemctl restart httpd.service
filebrowser -a "$IPV4" --port 8080 &
#usermod -a -G docker ec2-user

