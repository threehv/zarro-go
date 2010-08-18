#!/usr/bin/env ruby
# (c) 2009 3hv Limited 
# remove user - removes a user, mysql and rabbitmq account for zarro hosting
require 'optparse'
require 'yaml'
require 'logger'

class UserRemover
  attr_reader :username, :log, :details
  
  def initialize
    parser = OptionParser.new do | options | 
      options.banner = "Usage: remove-user.rb [options]"
      options.on '-u', '--user USERNAME', 'Specify the account name' do | value | 
        @username = value 
      end
      options.on_tail '-h', '--help', 'Show this message' do 
        puts options
        exit 1
      end
    end
    
    parser.parse!
    @log = Logger.new(STDOUT)
    
    log.info "Zarro remove-user - starting..."
    if @username.nil? 
      log.error "...failed: no username supplied"
      exit 1
    end
  end
  
  def go!
    remove_unix_user
    remove_mysql_user
    remove_rabbit_user
    return 0
  rescue Object => ex
    log.error "...failed: #{ex}"
    exit 1
  end
  
  def remove_unix_user
    log.info "...removing unix user"
    `userdel #{username}`
    log.info "...user #{username} removed"
  end
  
  def remove_mysql_user
    log.info "...removing mysql user"
    sql = "drop user '#{username}'@'localhost';"
		result = `mysql --defaults-file=mysql.cnf -e \"#{sql}\" `
    raise result unless result == ''
		log.info "...user #{username} removed"
  end
  
  def remove_rabbit_user
    log.info "...removing #{username} from RabbitMQ"
    result = `rabbitmq-ctl delete_user #{username}`
    raise result unless result = ""
    log.info "...RabbitMQ user #{username} removed"
  end 
  
end

remover = UserRemover.new
exit remover.go!