#!/usr/bin/env ruby
# script to set up a new application

require 'optparse'
require 'logger'

class ApplicationCreator
  attr_reader :path, :repo, :log
  def initialize
    parser = OptionParser.new do | options | 
      options.banner = "Usage: setup-application.rb [options]"
      options.on '-p', '--path PATH', 'Specify a path where the application will be placed' do | value |
        @path = value
      end
      options.on '-r', '--repo REPOSITORY', 'The git repository containing the application' do | value |
        @repo = value
      end
      options.on_tail '-h', '--help', 'Show this message' do 
        puts options
        exit 1
      end
    end
    parser.parse!
    raise "No path provided" if @path.nil?
    raise "No repo provided" if @repo.nil?
    @log = Logger.new(STDOUT)
  end
  
  def go!
    log.info "Creating application #{repo}"
    `cd #{path} && git clone #{@repo}`
  end
end

ac = ApplicationCreator.new
ac.go!