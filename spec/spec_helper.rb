require 'fileutils'

def make_dirs(*dirs)
  dirs.each do |dir|
    FileUtils.mkdir_p(dir)
  end
end

def make_file(path, content)
  d = File.dirname(path)
  FileUtils.mkdir_p(d) unless File.exist?(d)

  f = File.open(path, 'w')
  f.puts content
  f.close
end

def exec(cmd)
  system("#{cmd} > /dev/null")
  $?.to_s.split(/\s+/).last.to_i
end

def check_file(path, content)
  expect(File.exist?(path)).to eq(true), "The file #{path} should exist"

  if File.exist?(path)
    c = File.read(path).chomp
    expect(c).to eq(content), "File #{path} should contain [#{content}] but has [#{c}]"
  end
end
