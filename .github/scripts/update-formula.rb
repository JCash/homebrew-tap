#!/usr/bin/env ruby

require "rubygems"

unless ARGV.length == 4
  abort "usage: update-formula.rb FORMULA TAG SOURCE_URL SHA256"
end

path, tag, source_url, checksum = ARGV
version = tag.delete_prefix("v")

abort "invalid tag: #{tag}" unless tag.match?(/\Av\d+(?:\.\d+){1,3}\z/)
abort "invalid SHA-256: #{checksum}" unless checksum.match?(/\A[0-9a-f]{64}\z/)

contents = File.read(path)
current_version = contents[%r{/refs/tags/v([^/]+)\.tar\.gz"}, 1]

if current_version && Gem::Version.new(version) < Gem::Version.new(current_version)
  abort "refusing to downgrade #{current_version} to #{version}"
end

if current_version && Gem::Version.new(version) > Gem::Version.new(current_version)
  contents.sub!(/^  revision \d+\n/, "")
end

url_lines = contents.scan(/^  url ".*"$/)
checksum_lines = contents.scan(/^  sha256 ".*"$/)
abort "expected one url line" unless url_lines.length == 1
abort "expected one sha256 line" unless checksum_lines.length == 1

contents.sub!(/^  url ".*"$/, %(  url "#{source_url}"))
contents.sub!(/^  sha256 ".*"$/, %(  sha256 "#{checksum}"))
File.write(path, contents)
