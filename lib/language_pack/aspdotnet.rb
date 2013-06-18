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
      resources_dir = File.expand_path('../../../resources/iishost', __FILE__)
      FileUtils.cp_r(resources_dir, build_path)
    end

    def default_process_types
      {
        "web" => "iishost.exe"
      }
    end

  end
end

