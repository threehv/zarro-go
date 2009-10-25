#!/usr/bin/env ruby
# (c) 2009 3hv Limited 
# create user - creates a user account and mysql account for zarro hosting
require 'optparse'
require 'yaml'
require 'logger'

class UserCreator
  attr_reader :username, :password, :shell, :log, :details
  
  def initialize
    @details = {}
    
    parser = OptionParser.new do | options | 
      options.banner = "Usage: create-user.rb [options]"
      options.on '-u', '--user USERNAME', 'Specify the new account name' do | value | 
        @username = value 
      end
      options.on '-p', '--password PASSWORD', 'Specify a password to use (defaults to randomly generated)' do | value |
        @password = value
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
    @password ||= `pwgen 12 1`.strip
  end
  
  def go!
    add_unix_user
    add_mysql_user
    write_details
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
    result = `useradd #{switches} zr-#{username}`
    raise result unless result == ''

    log.info "...setting password to #{password}"
    double_password = "#{password}\n#{password}"
    result = `echo '#{double_password}' | passwd -q zr-#{username}`
    raise result unless result == ''

    details[:username] = "zr-#{username}"
    details[:password] = password

    log.info "...user zr-#{username} created"
  end
  
  def add_mysql_user
		sql = "GRANT ALL PRIVILEGES ON \\`#{username}%\\`.* "
		sql << "TO '#{username}'@'localhost' "
		sql << "IDENTIFIED BY '#{password}';"
		
		log.info "...adding #{username} to mysql"
		result = `mysql --defaults-file=mysql.cnf -e \"#{sql}\" `
    raise result unless result == ''
		log.info "...MySQL password: #{password}"
  end
  
  def write_details
    File.open("/home/zr-#{username}/.zarro.yml", 'w') do | file | 
      YAML.dump details, file 
    end
  end
end

creator = UserCreator.new
exit creator.go!