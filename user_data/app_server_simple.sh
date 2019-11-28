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
#yum -y install epel-release yum-utils  
amazon-linux-extras install epel php7.3
yum -y install mariadb-server mariadb  httpd.x86_64 php-mbstring php-pdo php-xml php-gd php-opcache php-mysqlnd php-pecl-zip automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel
#yum -y install php-fpm  
systemctl enable php-fpm.service
systemctl start php-fpm.service

mv  /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/.welcome.conf
sed -i 's/index.html/index.html index.php/g' /etc/httpd/conf/httpd.conf
sed -i '/IncludeOptional/d' /etc/httpd/conf/httpd.conf
mkdir -p /app/{filerun,logs} && chown -R apache.apache /app/filerun
chown apache.apache -R /app
cat<<EOF>> /etc/httpd/conf/httpd.conf 
<IfModule proxy_module>  
  ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000/app/filerun
</IfModule> 
IncludeOptional conf.d/*.conf
EOF

cat<<EOF> /etc/httpd/conf.d/filerun.conf
<VirtualHost *:80>
    ServerName filerun.net
    DocumentRoot "/app/filerun"
    ErrorLog /app/logs/filerun_error.log
    CustomLog /app/logs/filerun_access.log combined

    <Directory "/app/filerun/">
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF
#yum -y install php-mbstring php-opcache php-pdo php-mysqlnd php-gd php-xml php-zip

cd /usr/lib64/php/modules
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz  
tar xvfz ioncube_loaders_lin_x86-64.tar.gz 

cat<<EOF> /etc/php.d/01_filerun.ini
expose_php              = Off  
error_reporting         = E_ALL & ~E_NOTICE  
display_errors          = Off  
display_startup_errors  = Off  
log_errors              = On  
ignore_repeated_errors  = Off  
allow_url_fopen         = On  
allow_url_include       = Off  
variables_order         = "GPCS"  
allow_webdav_methods    = On  
memory_limit            = 128M  
max_execution_time      = 300  
output_buffering        = Off  
output_handler          = ""  
zlib.output_compression = Off  
zlib.output_handler     = ""  
safe_mode               = Off  
register_globals        = Off  
magic_quotes_gpc        = Off  
upload_max_filesize     = 1024M  
post_max_size           = 1024M  
enable_dl               = Off  
disable_functions       = ""  
disable_classes         = ""  
session.save_handler     = files  
session.use_cookies      = 1  
session.use_only_cookies = 1  
session.auto_start       = 0  
session.cookie_lifetime  = 0  
session.cookie_httponly  = 1  
date.timezone            = "UTC"
error_log               = "/app/logs/php_error.log"
zend_extension = /usr/lib64/php/modules/ioncube/ioncube_loader_lin_7.3.so 
EOF

## TODO### 
#replace  this ";listen = /run/php-fpm/www.sock" for this "listen = 127.0.0.1:9000"
sed -i  "s/listen\ =\ \/run\/php-fpm\/www\.sock/listen\ =\ 127\.0\.0\.1\:9000/g" /etc/php-fpm.d/www.conf
systemctl restart php-fpm.service



cd /app/filerun 
wget -O FileRun.zip http://www.filerun.com/download-latest && wget -O unzip.php http://f.afian.se/wl/?id=HS&filename=unzip.php&forceSave=1
chown -R apache:apache /app

systemctl start mariadb  
systemctl enable mariadb.service  
systemctl restart httpd.service
systemctl enable httpd.service  
#usermod -a -G docker ec2-user

### MYSQL ### 
mysqladmin -u root  password '${ROOT_PASS}'
cat<<EOF> /home/ec2-user/setup.sql
CREATE DATABASE filerun;
GRANT ALL ON filerun.* to 'filerun'@'localhost' IDENTIFIED BY '${FILERUN_PASS}';
FLUSH PRIVILEGES;
EOF
mysql -u root -p${ROOT_PASS} < /home/ec2-user/setup.sql
rm -f /home/ec2-user/setup.sql
