require "yaml"
require "fileutils"

module LanguagePack
  class Clr

    # C:\Program Files\Microsoft SDKs\Windows\v7.1>clrver
    # Versions installed on the machine:
    # v2.0.50727
    # v4.0.30319
    # http://msdn.microsoft.com/en-us/library/bb822049.aspx
    DEFAULT_CLR_VERSION = "4.0.30319".freeze

    def self.use?
      Dir.glob("**/Web.config").any? || Dir.glob("**/*.exe.config").any?
    end

    attr_reader :build_path, :cache_path

    # changes directory to the build_path
    # @param [String] the path of the build dir
    # @param [String] the path of the cache dir
    def initialize(build_path, cache_path=nil)
      @build_path = build_path
      @cache_path = cache_path
    end

    def name
      "CLR"
    end

    def compile
      Dir.chdir(build_path) do
        setup_profiled
      end
    end

    def release
      {
          "addons" => [],
          "config_vars" => {},
          "default_process_types" => default_process_types
      }.to_yaml
    end

    def default_process_types
      {}
    end

    def setup_profiled
    end

    # sets up environment
    # Anything with .sh is added to startup script and sourced when app is started (current behavior)
    def add_to_profiled(string)
      FileUtils.mkdir_p "#{build_path}/.profile.d"
      File.open("#{build_path}/.profile.d/clr.ps1", "a") do |file|
        file.puts string
      end
    end

    def set_env_default(key, val)
      add_to_profiled %{$env:#{key}="#{val}"}
    end

  end
end

