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

    def default_process_types
      {
        "web" => "IIS"
      }
    end

  end
end

