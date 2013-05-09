require "yaml"
require "fileutils"

module LanguagePack
  class Clr
    include LanguagePack::PackageFetcher

    # C:\Program Files\Microsoft SDKs\Windows\v7.1>clrver
    # Versions installed on the machine:
    # v2.0.50727
    # v4.0.30319
    # http://msdn.microsoft.com/en-us/library/bb822049.aspx
    DEFAULT_CLR_VERSION = "4.0.30319".freeze

    def self.use?
      Dir.glob("**/*.jar").any? || Dir.glob("**/*.class").any?
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
      "Clr"
    end

    def compile
      Dir.chdir(build_path) do
        install_java
        setup_profiled
      end
    end

    def install_java
      FileUtils.mkdir_p jdk_dir
      jdk_tarball = "#{jdk_dir}/jdk.tar.gz"

      download_jdk jdk_tarball

      puts "Unpacking JDK to #{jdk_dir}"
      tar_output = run_with_err_output "tar pxzf #{jdk_tarball} -C #{jdk_dir}"

      FileUtils.rm_rf jdk_tarball
      unless File.exists?("#{jdk_dir}/bin/java")
        puts "Unable to retrieve the JDK"
        puts tar_output
        exit 1
      end
    end

    def java_version
      @java_version ||= system_properties["java.runtime.version"] || DEFAULT_JDK_VERSION
    end

    def system_properties
      files = Dir.glob("**/system.properties")
      (!files.empty?) ? properties(files.first) :  {}
    end

    def download_jdk(jdk_tarball)
      puts "Downloading JDK..."
      fetched_package = fetch_jdk_package(java_version)
      FileUtils.mv fetched_package, jdk_tarball
    end

    def jdk_dir
      ".jdk"
    end

    def java_opts
      {
          "-Xmx" => "$MEMORY_LIMIT",
          "-Xms" => "$MEMORY_LIMIT",
          "-Djava.io.tmpdir=" => "$TMPDIR"
      }
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

    # run a shell comannd and pipe stderr to stdout
    # @param [String] command to be run
    # @return [String] output of stdout and stderr
    def run_with_err_output(command)
      %x{ #{command} 2>&1 }
    end

    def setup_profiled
      set_env_override "JAVA_HOME", "$HOME/#{jdk_dir}"
      set_env_override "PATH", "$HOME/#{jdk_dir}/bin:$PATH"
      set_env_default "JAVA_OPTS", java_opts.map{|k,v| "#{k}#{v}"}.join(' ')
      set_env_default 'LANG', 'en_US.UTF-8'
      add_debug_opts_to_profiled
    end

    def add_to_profiled(string)
      FileUtils.mkdir_p "#{build_path}/.profile.d"
      File.open("#{build_path}/.profile.d/java.sh", "a") do |file|
        file.puts string
      end
    end

    def set_env_default(key, val)
      add_to_profiled %{export #{key}="${#{key}:-#{val}}"}
    end

    def set_env_override(key, val)
      add_to_profiled %{export #{key}="#{val.gsub('"','\"')}"}
    end

    def debug_run_opts
      "-Xdebug -Xrunjdwp:transport=dt_socket,address=$VCAP_DEBUG_PORT,server=y,suspend=n"
    end

    def debug_suspend_opts
      "-Xdebug -Xrunjdwp:transport=dt_socket,address=$VCAP_DEBUG_PORT,server=y,suspend=y"
    end

    private
    def properties(props_file)
      properties = {}
      IO.foreach(props_file) do |line|
        if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~ /([^=]*)=(.*)/
          case $2
          when "true"
            properties[$1.strip] = true
          when "false"
            properties[$1.strip] = false
          else
            properties[$1.strip] = $2
          end
        end
      end
      properties
    end

    def add_debug_opts_to_profiled
      add_to_profiled(
        <<-DEBUG_BASH
if [ -n "$VCAP_DEBUG_MODE" ]; then
  if [ "$VCAP_DEBUG_MODE" = "run" ]; then
    export JAVA_OPTS="$JAVA_OPTS #{debug_run_opts}"
  elif [ "$VCAP_DEBUG_MODE" = "suspend" ]; then
    export JAVA_OPTS="$JAVA_OPTS #{debug_suspend_opts}"
  fi
fi
        DEBUG_BASH
)
    end
  end
end
