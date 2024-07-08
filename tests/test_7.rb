#!/usr/bin/env ruby

require 'fileutils'

require 'colorize'

$LOAD_PATH << './lib'

require 'helpers'

puts "Same file sizes but different contents (size)".green

%w[tmp tmp/m tmp/u].each { |path| Dir.mkdir(path) }

create_file('tmp/m/1.txt', '1')
create_file('tmp/u/1.txt', '2')

e = exit_code('merge --master tmp/m --updates tmp/u --check size > /dev/null')

if e == 0
  %w[tmp tmp/m tmp/u].each { |path| check_dir(path) }

  check_dir('tmp')
  check_dir('tmp/m')
  check_dir('tmp/u')
  check_file('tmp/m/1.txt', '1')
  check_file('tmp/u/1.txt', '2')
else
  puts "Failed with status #{e}".red
  exit
end

FileUtils.rm_rf('tmp')