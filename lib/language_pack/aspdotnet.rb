require "language_pack/clr"
require "fileutils"

# TODO logging
module LanguagePack
  class AspDotNet < Clr

    def self.use?
      File.exists?("Web.config") || File.exists?("web.config")
    end

    def name
      "ASP.NET"
    end

    def compile
      resources_dir = File.join(File.expand_path('../../../resources/iishost', __FILE__), '.') # NB: end with slash-dot to copy contents of iishost, not dir itself
      Dir.chdir(build_path) do
        FileUtils.mkdir_p(iishost_dir)
        FileUtils.cp_r(resources_dir, iishost_dir)
      end
    end

    def iishost_dir
      '.iishost'
    end

    def default_process_types
      {
        "web" => "./.iishost/iishost.exe"
      }
    end

  end
end

