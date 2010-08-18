#!/bin/sh

# system stuff
mkdir /boot/grub
apt-get --yes --force-yes update
apt-get --yes --force-yes upgrade 
apt-get --yes --force-yes install build-essential

# apache
apt-get --yes --force-yes install apache2

# ruby enterprise edition
apt-get --yes --force-yes install ruby1.8-dev
apt-get --yes --force-yes install libopenssl-ruby1.8
apt-get --yes --force-yes install zlib1g-dev
apt-get --yes --force-yes install libssl-dev
apt-get --yes --force-yes install libreadline5-dev
apt-get --yes --force-yes install libdbd-sqlite3-ruby1.8
apt-get --yes --force-yes install sqlite3
apt-get --yes --force-yes install libsqlite3-dev
apt-get --yes --force-yes install mysql-server
apt-get --yes --force-yes install libmysqlclient15-dev
apt-get --yes --force-yes install monit
apt-get --yes --force-yes install pwgen
mkdir /etc/monit.d

wget http://rubyforge.org/frs/download.php/64475/ruby-enterprise-1.8.7-20090928.tar.gz
tar xzvf ruby-enterprise-1.8.7-20090928.tar.gz
./ruby-enterprise-1.8.7-20090928/installer --auto /opt/ruby

ln -nfs /opt/ruby/bin/ruby /usr/bin/ruby
ln -nfs /opt/ruby/bin/gem /usr/bin/gem
ln -nfs /opt/ruby/bin/rake /usr/bin/rake
ln -nfs /opt/ruby/bin/irb /usr/bin/irb

# update rails
gem install mysql --no-ri --no-rdoc
gem install rails --no-ri --no-rdoc
ln -nfs /opt/ruby/bin/rails /bin/rails

# install git
apt-get --yes --force-yes install git-core

# set up passenger to allow apache to run a rails app
apt-get --yes --force-yes install apache2-prefork-dev
apt-get --yes --force-yes install libapr1-dev
mkdir /var/log/web
gem install passenger
cd /opt/ruby/bin
./passenger-install-apache2-module --auto
ln -nfs /opt/ruby/bin/passenger-status /bin/passenger-status

touch /etc/apache2/conf.d/passenger
cat >> /etc/apache2/conf.d/passenger <<-EOF
LoadModule passenger_module /opt/ruby/lib/ruby/gems/1.8/gems/passenger-2.2.15/ext/apache2/mod_passenger.so
PassengerRoot /opt/ruby/lib/ruby/gems/1.8/gems/passenger-2.2.15
PassengerRuby /opt/ruby/bin/ruby
PassengerMaxInstancesPerApp 2
EOF

rm /var/www/index.html
touch /var/www/index.html
cat >> /var/www/index.html <<-EOF
<html> <body> <h1> Server is go! </h1> </body> </html>
EOF

rm /etc/apache2/sites-enabled/000-default
touch /etc/apache2/sites-enabled/000-default
cat >> /etc/apache2/sites-enabled/000-default <<-EOF
<VirtualHost *:80>
  ServerName localhost
  DocumentRoot /var/www

  <Directory "/var/www">
    Options FollowSymLinks
    AllowOverride None
    Order allow,deny
    Allow from all
  </Directory>

  ErrorLog /var/log/apache2/error.log
  CustomLog /var/log/apache2/access.log combined

</VirtualHost>
EOF

/etc/init.d/apache2 restart

gem install brightbox-server-tools

ln -nfs /opt/ruby/bin/railsapp-logrotate /usr/bin/railsapp-logrotate
ln -nfs /opt/ruby/bin/railsapp-apache /usr/bin/railsapp-apache
ln -nfs /opt/ruby/bin/railsapp-maintenance /usr/bin/railsapp-maintenance
ln -nfs /opt/ruby/bin/railsapp-mongrel /usr/bin/railsapp-mongrel
ln -nfs /opt/ruby/bin/railsapp-monit /usr/bin/railsapp-monit
ln -nfs /opt/ruby/bin/railsapp-nginx /usr/bin/railsapp-nginx

cd ~
rm ruby-enterprise-1.8.7-20090928.tar.gz
rm -rf ruby-enterprise-1.8.7-20090928/

