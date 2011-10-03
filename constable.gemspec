# -*- encoding: utf-8 -*-
lib = File.expand_path '../lib/', __FILE__
$:.unshift lib unless $:.include? lib

require 'constable/version'

Gem::Specification.new do |s|
  s.name        = "constable"
  s.version     = Constable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Craig R Webster"]
  s.email       = ["craig@barkingiguana.com"]
  s.summary     = "ImageMagick as a service"
  s.description = "Installing ImageMagick and RMagick everywhere sucks, right? So install it in one place and have everything else use that one install."

  s.files       = Dir.glob("{lib,bin}/**/*") + %w(README.md)
  s.executables = Dir.glob("bin/**/*").map { |bin| bin.gsub(/^bin\//, '') }

  s.add_dependency 'stomp'
  s.requirements << 'A broker capable of talking Stomp'
end
