#!/usr/bin/env ruby

# sync output
$stdout.sync = true

$:.unshift File.expand_path("../../lib", __FILE__)
require "language_pack"

if pack = LanguagePack.detect(ARGV[0], ARGV[1])
  #TODO re-enable?
  #pack.log("compile") do
    pack.compile
  #end
end
