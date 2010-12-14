= Zarro Server Setup

Stuff to get a Debian/Ubuntu server up and running with Ruby Enterprise Edition, Rails and Passenger.  

== Usage

* Get a blank Ubuntu box, log in as root (or whatever your admin user is)
* Copy your public SSH key onto the box
* Place it in ~/.ssh/authorized_keys
* Copy ~/.ssh/authorized_keys to /etc/skel/.ssh
* Copy the setup script onto the box
* Run the script as root

    sudo setup-server.sh
    
* It requires intervention at two points - postfix and mysql's root password
* Then mv mysql.cnf.template mysql.cnf
* Edit it and enter your mysql username and password
* Use create-user.rb -u USERNAME -p PASSWORD to add new users to the system
* Edit /etc/ssh/sshd_config to disallow root logins and restart sshd - DO NOT CLOSE YOUR TERMINAL
* Log in as your new user from a new terminal to check you can log in OK
* Create a backup folder under whichever user you want
* Put the backup-database and copy-to-s3 scripts in there
* Edit the two scripts, adding in folder names and your S3 keys
* Crontab the two scripts