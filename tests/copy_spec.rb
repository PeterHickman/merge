require 'fileutils'

def make_dirs(*dirs)
  dirs.each do |dir|
    Dir.mkdir(dir)
  end
end

def make_file(path, content)
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

describe 'Copy a file' do
  before do
    FileUtils.rm_rf('tmp') if File.exists?('tmp')
  end

  after do
    FileUtils.rm_rf('tmp') if File.exists?('tmp')
  end

  context 'a new file' do
    before do
      make_dirs('tmp', 'tmp/m', 'tmp/u')
      make_file('tmp/u/1.txt', '1')
    end

    context '--check size' do
      it 'copies the file' do
        s = exec('merge --master tmp/m --updates tmp/u --check size')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/u/1.txt', '1')
      end
    end

    context '--check md5' do
      it 'copies the file' do
        s = exec('merge --master tmp/m --updates tmp/u --check md5')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/u/1.txt', '1')
      end
    end

    context '--check sha256' do
      it 'copies the file' do
        s = exec('merge --master tmp/m --updates tmp/u --check sha256')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/u/1.txt', '1')
      end
    end

    context '--check same' do
      it 'copies the file' do
        s = exec('merge --master tmp/m --updates tmp/u --check same')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/u/1.txt', '1')
      end
    end
  end

  context 'an updated file' do
    before do
      make_dirs('tmp', 'tmp/m', 'tmp/u')
      make_file('tmp/m/1.txt', '1')
      make_file('tmp/u/1.txt', '2')
    end

    context '--check size' do
      it 'does not copy the file' do
        s = exec('merge --master tmp/m --updates tmp/u --check size')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/u/1.txt', '2')
      end
    end

    context '--check md5' do
      it 'copies the file' do
        s = exec('merge --master tmp/m --updates tmp/u --check md5')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '2')
        check_file('tmp/u/1.txt', '2')
      end
    end

    context '--check sha256' do
      it 'copies the file' do
        s = exec('merge --master tmp/m --updates tmp/u --check sha256')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '2')
        check_file('tmp/u/1.txt', '2')
      end
    end

    context '--check same' do
      it 'does not copy the file' do
        s = exec('merge --master tmp/m --updates tmp/u --check same')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/u/1.txt', '2')
      end
    end
  end

  context 'a new file is a new directory' do
    before do
      make_dirs('tmp', 'tmp/m', 'tmp/u', 'tmp/u/x')
      make_file('tmp/m/1.txt', '1')
      make_file('tmp/u/x/1.txt', '2')
    end

    context '--check size' do
      it 'copies the file' do
        s = exec('merge --master tmp/m --updates tmp/u --check size')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/m/x/1.txt', '2')
        check_file('tmp/u/x/1.txt', '2')
      end
    end

    context '--check md5' do
      it 'copies the file' do
        s = exec('merge --master tmp/m --updates tmp/u --check md5')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/m/x/1.txt', '2')
        check_file('tmp/u/x/1.txt', '2')
      end
    end

    context '--check sha256' do
      it 'copies the file' do
        s = exec('merge --master tmp/m --updates tmp/u --check sha256')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/m/x/1.txt', '2')
        check_file('tmp/u/x/1.txt', '2')
      end
    end

    context '--check same' do
      it 'copies the file' do
        s = exec('merge --master tmp/m --updates tmp/u --check same')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/m/x/1.txt', '2')
        check_file('tmp/u/x/1.txt', '2')
      end
    end
  end
end