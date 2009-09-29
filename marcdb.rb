#!/usr/bin/env ruby
require 'rubygems'
require 'marc'
require 'models'

if ARGV.empty?
  puts "Usage:  marcdb command [options]\n\n'command' is one of: init, load, view"
  exit
end

case ARGV[0]
when "init"
  puts "Initializing database."
  DataMapper.auto_migrate!
  puts "Complete."
when "load"
  unless ARGV[1]
    puts "No file or path given to load!"
    exit
  end
  unless ARGV[2]
    puts "Usage: marcdb load [file] [marc|xml]"
    exit
  end
  require 'loader'
  load_files(ARGV[1], ARGV[2])
when "view"
  control_number = ControlField.first(:tag=>'001', :value=>ARGV[1])
  if control_number
    puts control_number.record.to_marc
  else
    puts "Record #{ARGV[1]} not found!"
  end
  exit
end