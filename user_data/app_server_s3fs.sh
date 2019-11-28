HOME=/home/ec2-user
PROYECTOS=/home/ec2-user/proyectos
PROYECTOS_FILERUN=/app/filebrowser/bucket
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
mkdir -p $PROYECTOS_FILERUN  && chown ec2-user.ec2-user -R $PROYECTOS_FILERUN
sed -i 's/^\#//g' /etc/fuse.conf
sudo -u ec2-user s3fs  ${BUCKET}  -o use_cache=/tmp -o allow_other -o uid=1000 -o mp_umask=002 -o multireq_max=5  -o dbglevel=info  -o url=https://s3-us-west-1.amazonaws.com -o endpoint=us-west-1  $PROYECTOS_FILERUN
usermod -G ec2-user -a apache
sudo -u apache mkdir $PROYECTOS_FILERUN/{proyectos,usuarios}
