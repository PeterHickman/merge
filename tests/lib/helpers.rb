def create_file(name, text)
  f = File.open(name, 'w')
  f.puts text
  f.close
end

def exit_code(cmd)
  system(cmd)
  $?.to_s.split(/\s+/).last.to_i
end

def check_dir(path)
  if File.exist?(path)
    unless File.directory?(path)
      puts "#{path} should be a directory".red
    end
  else
    puts "#{path} is missing".red
  end
end

def check_file(path, text)
  if File.exist?(path)
    c = File.read(path).chomp
    unless c == text
      puts "#{path} contents expected [#{text}] was [#{c}]".red
    end
  else
    puts "#{path} is missing".red
  end
end
