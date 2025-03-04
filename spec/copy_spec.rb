require 'spec_helper'

describe 'Copy a file' do
  before :all do
    system('go build merge.go')
  end

  after :all do
    system('rm merge')
  end

  before :each do
    FileUtils.rm_rf('tmp') if File.exists?('tmp')
  end

  after :each do
    FileUtils.rm_rf('tmp') if File.exists?('tmp')
  end

  context 'a new file' do
    before do
      make_dirs('tmp/m', 'tmp/u')
      make_file('tmp/u/1.txt', '1')
    end

    context '--check size' do
      it 'copies the file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check size')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/u/1.txt', '1')
      end
    end

    context '--check md5' do
      it 'copies the file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check md5')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/u/1.txt', '1')
      end
    end

    context '--check sha256' do
      it 'copies the file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check sha256')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/u/1.txt', '1')
      end
    end

    context '--check same' do
      it 'copies the file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check same')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/u/1.txt', '1')
      end
    end
  end

  context 'an updated file' do
    before do
      make_dirs('tmp/m', 'tmp/u')
      make_file('tmp/m/1.txt', '1')
      make_file('tmp/u/1.txt', '2')
    end

    context '--check size' do
      it 'does not copy the file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check size')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/u/1.txt', '2')
      end
    end

    context '--check md5' do
      it 'copies the file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check md5')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '2')
        check_file('tmp/u/1.txt', '2')
      end
    end

    context '--check sha256' do
      it 'copies the file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check sha256')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '2')
        check_file('tmp/u/1.txt', '2')
      end
    end

    context '--check same' do
      it 'does not copy the file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check same')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/u/1.txt', '2')
      end
    end
  end

  context 'a new file is a new directory' do
    before do
      make_dirs('tmp/m', 'tmp/u', 'tmp/u/x')
      make_file('tmp/m/1.txt', '1')
      make_file('tmp/u/x/1.txt', '2')
    end

    context '--check size' do
      it 'copies the file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check size')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/m/x/1.txt', '2')
        check_file('tmp/u/x/1.txt', '2')
      end
    end

    context '--check md5' do
      it 'copies the file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check md5')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/m/x/1.txt', '2')
        check_file('tmp/u/x/1.txt', '2')
      end
    end

    context '--check sha256' do
      it 'copies the file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check sha256')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/m/x/1.txt', '2')
        check_file('tmp/u/x/1.txt', '2')
      end
    end

    context '--check same' do
      it 'copies the file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check same')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '1')
        check_file('tmp/m/x/1.txt', '2')
        check_file('tmp/u/x/1.txt', '2')
      end
    end
  end

  context 'a deeply nested new file' do
    before do
      make_dirs('tmp/m', 'tmp/u')
      make_file('tmp/u/a/b/c/d/e/1.txt', '1')
    end

    it 'copies the file' do
      s = exec('./merge --master tmp/m --updates tmp/u --check size')
      expect(s).to eq(0), "merge should run without error, got #{s}"

      check_file('tmp/m/a/b/c/d/e/1.txt', '1')
    end
  end

  context 'a new (empty) directory' do
    before do
      make_dirs('tmp/m', 'tmp/u', 'tmp/u/x')
    end

    it 'creates the directory' do
      s = exec('./merge --master tmp/m --updates tmp/u --check size')
      expect(s).to eq(0), "merge should run without error, got #{s}"

      check_dir('tmp/m/x')
    end
  end

  context 'dry run is true' do
    context '--check md5 is used for all tests' do
      before do
        make_dirs('tmp/m', 'tmp/u')
        make_file('tmp/u/1.txt', '1')
      end

      it 'does not copy a new file' do
        s = exec('./merge --master tmp/m --updates tmp/u --check size --dry-run')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_not_file('tmp/m/1.txt')
      end

      it 'does not update an existing file' do
        make_file('tmp/m/1.txt', '2')

        s = exec('./merge --master tmp/m --updates tmp/u --check size --dry-run')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1.txt', '2')
      end
    end

    context 'a new (empty) directory' do
      before do
        make_dirs('tmp/m', 'tmp/u', 'tmp/u/x')
      end

      it 'does not create the directory' do
        s = exec('./merge --master tmp/m --updates tmp/u --dry-run')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_not_dir('tmp/m/x')
      end
    end
  end

  context 'filenames with spaces' do
    before do
      make_dirs('tmp/m', 'tmp/u')
    end

    context 'file with a space' do
      it 'should copy the file' do
        make_file('tmp/u/1 2 3.txt', '1')

        s = exec('./merge --master tmp/m --updates tmp/u')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/1 2 3.txt', '1')
      end
    end

    context 'directory with a space' do
      it 'should copy the file' do
        make_file('tmp/u/a b c d e/1.txt', '1')

        s = exec('./merge --master tmp/m --updates tmp/u')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/a b c d e/1.txt', '1')
      end
    end
  end

  context 'filenames with odd characters' do
    before do
      make_dirs('tmp/m', 'tmp/u')
    end

    context 'file with odd characters' do
      it 'should copy the file' do
        make_file('tmp/u/🇯🇵Tokyo walk - Kanda Station to Akihabara.txt', '1')
        make_file('tmp/u/小雨の品川シーサイドを散歩 2024 Rainy Shinagawa Seaside.txt', '2')

        s = exec('./merge --master tmp/m --updates tmp/u')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/m/🇯🇵Tokyo walk - Kanda Station to Akihabara.txt', '1')
        check_file('tmp/m/小雨の品川シーサイドを散歩 2024 Rainy Shinagawa Seaside.txt', '2')
      end
    end

    context 'directory with odd characters' do
      it 'should copy the file' do
        make_file('tmp/u/🇯🇵Tokyo walk - Kanda Station to Akihabara/1.txt', '1')
        make_file('tmp/u/小雨の品川シーサイドを散歩 2024 Rainy Shinagawa Seaside/2.txt', '2')

        s = exec('./merge --master tmp/m --updates tmp/u')
        expect(s).to eq(0), "merge should run without error, got #{s}"

        check_file('tmp/u/🇯🇵Tokyo walk - Kanda Station to Akihabara/1.txt', '1')
        check_file('tmp/u/小雨の品川シーサイドを散歩 2024 Rainy Shinagawa Seaside/2.txt', '2')
      end
    end
  end

  context 'exclude files matching a pattern' do
    before do
      make_dirs('tmp/m', 'tmp/u')
    end

    it 'should not copy *.bak files' do
      make_file('tmp/u/file.bak', '1')
      make_file('tmp/u/new.txt', '2')

      s = exec("./merge --master tmp/m --updates tmp/u --exclude '*.bak'")
      expect(s).to eq(0), "merge should run without error, got #{s}"

      check_not_file('tmp/m/file.bak')
      check_file('tmp/m/new.txt', '2')
    end

    it 'should handle multiple excludes' do
      make_file('tmp/u/file.bak', '1')
      make_file('tmp/u/new.txt', '2')
      make_file('tmp/u/fred.old', '3')

      s = exec('./merge --master tmp/m --updates tmp/u --exclude "*.bak" --exclude "*.old"')
      expect(s).to eq(0), "merge should run without error, got #{s}"

      check_not_file('tmp/m/file.bak')
      check_file('tmp/m/new.txt', '2')
      check_not_file('tmp/m/fred.old')
    end

    it 'should exclude however the pattern matches' do
      make_file('tmp/u/file-partial', '1')
      make_file('tmp/u/file-partial-2', '2')
      make_file('tmp/u/fred.txt', '3')

      s = exec('./merge --master tmp/m --updates tmp/u --exclude "*-partial*" ')
      expect(s).to eq(0), "merge should run without error, got #{s}"

      check_not_file('tmp/m/file-partial')
      check_not_file('tmp/m/file-partial-2')
      check_file('tmp/m/fred.txt', '3')
    end

    it 'should copy these names' do
      make_file('tmp/u/sha256-6e4c38e1172f42fdbff13edf9a7a017679fb82b0fde415a3e8b3c31c6ed4a4e4e-partial-1', '1')
      make_file('tmp/u/sha256-6e4c38e1172f42fdbff13edf9a7a017679fb82b0fde415a3e8b3c31c6ed4a4e4e-partial-2', '2')

      s = exec('./merge --master tmp/m --updates tmp/u --exclude "*-partial*" ')
      expect(s).to eq(0), "merge should run without error, got #{s}"

      check_not_file('tmp/m/sha256-6e4c38e1172f42fdbff13edf9a7a017679fb82b0fde415a3e8b3c31c6ed4a4e4e-partial-1')
      check_not_file('tmp/m/sha256-6e4c38e1172f42fdbff13edf9a7a017679fb82b0fde415a3e8b3c31c6ed4a4e4e-partial-2')
    end
  end
end
