#!/usr/bin/env bash

sudo -i -u vagrant /usr/bin/env bash - << eof

source /home/vagrant/.phpbrew/bashrc

echo "===> Connect to remote database"
ssh -fNg -L 3307:localhost:3306 bieda@bieda.org

phpbrew switch php-7
phpbrew fpm start

eof
