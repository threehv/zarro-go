#!/usr/bin/env ruby
# (c) 2009 3hv Limited 
# create user - creates a user account and mysql account for zarro hosting
require 'optparse'
require 'logger'

class UserCreator
  attr_reader :username, :shell, :log
  
  def initialize
    parser = OptionParser.new do | options | 
      options.banner = "Usage: create-user.rb [options]"
      options.on '-u', '--user USERNAME', 'Specify the new account name' do | value | 
        @username = value 
      end
      options.on '-s', '--shell SHELL', 'Specify the shell (defaults to /bin/bash)' do | value | 
        @shell = value
      end
      options.on_tail '-h', '--help', 'Show this message' do 
        puts options
        exit 1
      end
    end
    
    parser.parse!
    @log = Logger.new(STDOUT)
    
    log.info "Zarro create-user - starting..."
    if @username.nil? 
      log.error "...failed: no username supplied"
      exit 1
    end
    @shell ||= '/bin/bash'
  end
  
  def go!
    add_unix_user
    add_mysql_user
    return 0
  rescue Object => ex
    log.error "...failed: #{ex}"
    exit 1
  end
  
  def add_unix_user
    switches = ''
    switches += " --shell=#{shell} "
    switches += ' --create-home '
    
    log.info "...creating user"
    result = `useradd #{switches} ors-#{username}`
    raise result unless result == ''

    log.info "...setting password"
    result = `passwd ors-#{username}`
    raise result unless result == ''

    log.info "...user ors-#{username} created"
  end
  
  def add_mysql_user
    password = `pwgen 12 1`
		sql = "GRANT ALL PRIVILEGES ON \`ors-#{username}%\`.* "
		sql << "TO 'ors-#{username}'@'localhost' "
		sql << "IDENTIFIED BY '#{password}';"
		
		log.info "...adding ors-#{username} to mysql"
		result = `mysql --defaults-file=mysql.cnf -e \"#{sql}\" `
		log.info "...with result: #{result}"
  end
end

creator = UserCreator.new
exit creator.go!