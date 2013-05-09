require "language_pack/java"
require "language_pack/database_helpers"
require "fileutils"

# TODO logging
module LanguagePack
  class JavaWeb < Java
    include LanguagePack::PackageFetcher
    include LanguagePack::DatabaseHelpers

    TOMCAT_PACKAGE =  "apache-tomcat-7.0.37.tar.gz".freeze
    WEBAPP_DIR = "webapps/ROOT/".freeze

    def self.use?
      File.exists?("WEB-INF/web.xml") || File.exists?("webapps/ROOT/WEB-INF/web.xml")
    end

    def name
      "Java Web"
    end

    def compile
      Dir.chdir(build_path) do
        install_java
        install_tomcat
        remove_tomcat_files
        copy_webapp_to_tomcat
        move_tomcat_to_root
        install_database_drivers
        #install_insight
        copy_resources
        setup_profiled
      end
    end

    def install_tomcat
      FileUtils.mkdir_p tomcat_dir
      tomcat_tarball="#{tomcat_dir}/tomcat.tar.gz"

      download_tomcat tomcat_tarball

      puts "Unpacking Tomcat to #{tomcat_dir}"
      run_with_err_output("tar xzf #{tomcat_tarball} -C #{tomcat_dir} && mv #{tomcat_dir}/apache-tomcat*/* #{tomcat_dir} && " +
              "rm -rf #{tomcat_dir}/apache-tomcat*")
      FileUtils.rm_rf tomcat_tarball
      unless File.exists?("#{tomcat_dir}/bin/catalina.sh")
        puts "Unable to retrieve Tomcat"
        exit 1
      end
    end

    def download_tomcat(tomcat_tarball)
      puts "Downloading Tomcat: #{TOMCAT_PACKAGE}"
      fetch_package TOMCAT_PACKAGE, "http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.37/bin/"
      FileUtils.mv TOMCAT_PACKAGE, tomcat_tarball
    end

    def remove_tomcat_files
      %w[NOTICE RELEASE-NOTES RUNNING.txt LICENSE temp/. webapps/. work/. logs].each do |file|
        FileUtils.rm_rf("#{tomcat_dir}/#{file}")
      end
    end

    def tomcat_dir
      ".tomcat"
    end

    def copy_webapp_to_tomcat
      run_with_err_output("mkdir -p #{tomcat_dir}/webapps/ROOT && mv * #{tomcat_dir}/webapps/ROOT")
    end

    def move_tomcat_to_root
      run_with_err_output("mv #{tomcat_dir}/* . && rm -rf #{tomcat_dir}")
    end

    def copy_resources
      # Configure server.xml with variable HTTP port
      run_with_err_output("cp -r #{File.expand_path('../../../resources/tomcat', __FILE__)}/* #{build_path}")
    end

    def java_opts
      # TODO proxy settings?
      # Don't override Tomcat's temp dir setting
      opts = super.merge({ "-Dhttp.port=" => "$PORT" })
      opts.delete("-Djava.io.tmpdir=")
      opts
    end

    def default_process_types
      {
        "web" => "./bin/catalina.sh run"
      }
    end

    def webapp_path
      File.join(build_path,"webapps","ROOT")
    end
  end
end
