HOME=/home/ec2-user
PROYECTOS_PYDIO=/var/lib/pydio/personal
APACHE_UID=$(cat /etc/passwd| grep apache | cut -d : -f 3)
cd $HOME 
git clone https://github.com/s3fs-fuse/s3fs-fuse.git
cd s3fs-fuse
./autogen.sh
./configure --prefix=/usr --with-openssl
make
sudo make install
#echo "${ACCESS_KEY}:${SECRET_KEY}" > /etc/passwd-s3fs
echo "${ACCESS_KEY}:${SECRET_KEY}" > /home/ec2-user/.passwd-s3fs
#chmod 640 /etc/passwd-s3fs
chown ec2-user.ec2-user /home/ec2-user/.passwd-s3fs && chmod 600 /home/ec2-user/.passwd-s3fs
usermod -G apache -a ec2-user
sed -i 's/^\#//g' /etc/fuse.conf
rm -f /var/lib/pydio/personal/.htaccess
chmod 777  /var/lib/pydio/personal/
sudo -u ec2-user s3fs  ${BUCKET}  -o use_cache=/tmp -o allow_other -o uid=$APACHE_UID -o mp_umask=002 -o multireq_max=5  -o dbglevel=info  -o url=https://s3-us-west-1.amazonaws.com -o endpoint=us-west-1  $PROYECTOS_PYDIO
cat<<EOF > /var/lib/pydio/personal/.htaccess
deny from all
EOF
chown apache.apache /var/lib/pydio/personal/.htaccess && chmod 755 /var/lib/pydio/personal/.htaccess
