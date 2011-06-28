# All this done as root

echo "Need to run as root"
echo "Expect /etc/skel/.ssh to contain keys"

# Add brightbox repositories
wget http://apt.brightbox.net/release.asc -O - | apt-key add -
wget -c http://apt.brightbox.net/sources/lucid/brightbox.list -P /etc/apt/sources.list.d/
wget -c http://apt.brightbox.net/sources/lucid/rubyee.list -P /etc/apt/sources.list.d/
# Grab the packages
aptitude update

# Install ruby/ruby-ee/rubygems
aptitude -y install ruby1.8 ruby1.8-dev ri1.8 rdoc1.8 irb1.8 ruby1.8-examples libdbm-ruby1.8 libgdbm-ruby1.8 libtcltk-ruby1.8 libopenssl-ruby1.8 libreadline-ruby1.8 ruby ri rdoc irb rubygems1.8

# Install some basic gems
gem install rake

# Install git & sqlite3
aptitude -y install git-core sqlite3 libsqlite3-dev

# Install apache
mkdir -p /var/log/web
aptitude -y install apache2 apache2-utils apache2-mpm-worker

echo 'ServerRoot "/etc/apache2"

LockFile /var/lock/apache2/accept.lock

PidFile ${APACHE_PID_FILE}

# Timeout: The number of seconds before receives and sends time out.
Timeout 300

# KeepAlive: Whether or not to allow persistent connections (more than
# one request per connection). Set to "Off" to deactivate.
KeepAlive On

# MaxKeepAliveRequests: The maximum number of requests to allow
# during a persistent connection. Set to 0 to allow an unlimited amount.
# We recommend you leave this number high, for maximum performance.
MaxKeepAliveRequests 100

# KeepAliveTimeout: Number of seconds to wait for the next request from the
# same client on the same connection.
KeepAliveTimeout 15

# prefork MPM
# StartServers: number of server processes to start
# MinSpareServers: minimum number of server processes which are kept spare
# MaxSpareServers: maximum number of server processes which are kept spare
# MaxClients: maximum number of server processes allowed to start
# MaxRequestsPerChild: maximum number of requests a server process serves
<IfModule mpm_prefork_module>
    StartServers          5
    MinSpareServers       5
    MaxSpareServers      10
    MaxClients          150
    MaxRequestsPerChild   0
</IfModule>

# worker MPM
# StartServers: initial number of server processes to start
# MaxClients: maximum number of simultaneous client connections
# MinSpareThreads: minimum number of worker threads which are kept spare
# MaxSpareThreads: maximum number of worker threads which are kept spare
# ThreadsPerChild: constant number of worker threads in each server process
# MaxRequestsPerChild: maximum number of requests a server process serves
<IfModule mpm_worker_module>
    StartServers          2
    MaxClients          150
    MinSpareThreads      25
    MaxSpareThreads      75 
    ThreadsPerChild      25
    MaxRequestsPerChild   0
</IfModule>

# These need to be set in /etc/apache2/envvars
User ${APACHE_RUN_USER}
Group ${APACHE_RUN_GROUP}

AccessFileName .htaccess

# The following lines prevent .htaccess and .htpasswd files from being 
# viewed by Web clients. 
<Files ~ "^\.ht">
    Order allow,deny
    Deny from all
    Satisfy all
</Files>

DefaultType text/plain


HostnameLookups Off

ErrorLog /var/log/apache2/error.log

LogLevel warn

# Include module configuration:
Include /etc/apache2/mods-enabled/*.load
Include /etc/apache2/mods-enabled/*.conf

# Include all the user configurations:
Include /etc/apache2/httpd.conf

# Include ports listing
Include /etc/apache2/ports.conf

LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %O" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent

ServerTokens Minimal

ServerSignature On

# Include generic snippets of statements
Include /etc/apache2/conf.d/

ServerName localhost
NameVirtualHost *:80

# Include the virtual host configurations:
Include /etc/apache2/sites-enabled/
' > /etc/apache2/apache2.conf
# Restart apache
/etc/init.d/apache2 restart

# Install postfix for monit to use
aptitude -y install postfix # hit ok on the config screens, accept the default

# Install monit
aptitude -y install monit
mv /etc/monit/monitrc /etc/monit/monitrc.dpkg-dist

echo "# Monit configuration
# for more details see http://wiki.brightbox.co.uk/Support/Monit
set daemon 30

set mailserver localhost

include /etc/monit/conf.d/*.monitrc
" > /etc/monit/monitrc

echo "check device rootfs with path /dev/vda1
  if space usage > 90% 5 times within 15 cycles then alert
  mode passive
" > /etc/monit/conf.d/disk-space.monitrc

echo "set logfile syslog facility log_daemon 
set httpd port 2812 and
    use address localhost # and only accept connection from localhost
    allow localhost       # allow localhost to connect to the server and
" > /etc/monit/conf.d/general.monitrc

echo "set alert alerts@3hv.co.uk
" > /etc/monit/conf.d/email-alerts.monitrc

# Mark monit as being ok to start
cat /etc/default/monit | sed -e "s/startup=0/startup=1/" > /etc/default/monit.new
mv /etc/default/monit.new /etc/default/monit
# Start monit
/etc/init.d/monit start

aptitude -y install mysql-server libmysqlclient15-dev imagemagick libxml2-dev libxslt-dev libcurl4-openssl-dev

aptitude -y install libapache2-mod-passenger