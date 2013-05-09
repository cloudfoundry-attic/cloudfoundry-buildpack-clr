require "bundler"
Bundler.require :default, :test
require "tmpdir"
require "language_pack"

RSpec.configure do |config|
  config.before(:each, type: :with_temp_dir) do
    @tmpdir = Dir.mktmpdir
  end

  config.after(:each, type: :with_temp_dir) do
    FileUtils.rm_r(@tmpdir)
  end
end

def make_scratch_dir(dir)
  path = @tmpdir + '/' + dir
  FileUtils.mkdir_p(path)
  path
end
