require "language_pack/clr"
require "fileutils"

module LanguagePack
  class ClrConsole < Clr

    def self.use?
      Dir.glob("*.exe.config").any?
    end

    def name
      "ClrConsole"
    end

    def default_process_types
      {
        "web" => "Console" # TODO what is this for really?
      }
    end

  end
end

