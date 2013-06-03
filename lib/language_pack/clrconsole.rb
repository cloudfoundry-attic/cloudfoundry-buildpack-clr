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

  end
end

