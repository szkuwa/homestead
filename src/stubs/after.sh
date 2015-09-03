#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.


############### Install PHP7

# download dependencies
echo "===> Downloading php7 build dependencies"
apt-get -qq install -y libxml2-dev \
libbz2-dev \
libc-client2007e-dev \
libcurl4-gnutls-dev \
libfreetype6-dev \
libgmp3-dev \
libjpeg62-dev \
libkrb5-dev \
libmcrypt-dev \
libpng12-dev \
libssl-dev \
libxslt1-dev \
bison

echo "===> Disable system php5-fpm"
service php5-fpm stop

# switching user
sudo -i -u vagrant /usr/bin/env bash - << eof

# download php brewer
curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew
chmod +x phpbrew
sudo mv phpbrew /usr/bin/phpbrew

phpbrew init

# source brewer
printf "\n# source phpbrew\nsource ~/.phpbrew/bashrc\n" >> /home/vagrant/.profile
#printf "\n# source phpbrew\nsource ~/.phpbrew/bashrc\n" >> /home/vagrant/.bashrc

source /home/vagrant/.phpbrew/bashrc

# download and install master branch
echo "===> Download and install latest php master branch"
phpbrew install next as php-7 +default +fpm +mcrypt +openssl +gd +mysql +pdo +sqlite

# switch to php7
echo "===> Switch to use php7"
phpbrew switch php-7

eof

echo "===> Copy relevant www.conf to fpm directory"
cp /etc/php5/fpm/pool.d/www.conf /home/vagrant/.phpbrew/php/php-7/etc/php-fpm.d/www.conf

echo "===> Correct fpm sock addresses"
for file in /etc/nginx/sites-enabled/*.local; do
    sed -i.old 's/fastcgi_pass unix:\/var\/run\/php5-fpm\.sock;/fastcgi_pass unix:\/home\/vagrant\/\.phpbrew\/php-fpm\.sock;/g' "${file}"
done
for file in /home/vagrant/.phpbrew/php/php-7/etc/php-fpm.d/*.conf; do
    sed -i.old 's/listen = \/var\/run\/php5-fpm\.sock/listen = \/home\/vagrant\/\.phpbrew\/php-fpm\.sock/g' "${file}"
done

service nginx reload

sudo -i -u vagrant /usr/bin/env bash - << eof

source /home/vagrant/.phpbrew/bashrc

echo "===> Start php7 fpm"
phpbrew fpm start

eof

echo "===> Install additional packages"
apt-get -qq install -y byobu mc

echo "===> Add known hosts"
echo "|1|bObi/BNAO+/j/Ylz5QxaARwgebg=|rt/ZL4FVXy4ly/chpSGIIxP+Awg= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq7nBB8cIQId4Pu/SEXQ65wDAGsu5dlG79P/xua9eF/tonYRl+ub3ILKej+rk30VZsaJ/gMqcC5qPxzNiOSCBHuKjuqO4bQKpMN26FSSoxfpZQPLIijeNBz8bVFOvtMGOKE6X/pKnJ0ATFhPU43G5RHkQ6y2bGAr2UMoWFP9x4G6C3WluALFczmGOKejLKiAMARpGumlfLOAeJlPiA1bDt8vmgznXzGIQHkHkMYA2xIzYVjHpNpsxOSNZoMcKK5U1EU3nt2G4QYQFYzV3S2XNVY4EjowH+hbC8+nWDSJjE48w0HRd9PMWsxO7s5jZ61iUYTsy3TXKYGKS/Et2oOTVyw==
|1|iHjIYFXzvCkPqE7ZBoHz4Jhv4tI=|BsHaP2XrO5SRzJ4DFMCjtAQqp4M= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq7nBB8cIQId4Pu/SEXQ65wDAGsu5dlG79P/xua9eF/tonYRl+ub3ILKej+rk30VZsaJ/gMqcC5qPxzNiOSCBHuKjuqO4bQKpMN26FSSoxfpZQPLIijeNBz8bVFOvtMGOKE6X/pKnJ0ATFhPU43G5RHkQ6y2bGAr2UMoWFP9x4G6C3WluALFczmGOKejLKiAMARpGumlfLOAeJlPiA1bDt8vmgznXzGIQHkHkMYA2xIzYVjHpNpsxOSNZoMcKK5U1EU3nt2G4QYQFYzV3S2XNVY4EjowH+hbC8+nWDSJjE48w0HRd9PMWsxO7s5jZ61iUYTsy3TXKYGKS/Et2oOTVyw==" >> /home/vagrant/.ssh/known_hosts
chown vagrant:vagrant /home/vagrant/.ssh/known_hosts
