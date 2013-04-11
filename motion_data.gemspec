# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'motion_data/version'

Gem::Specification.new do |gem|
  gem.name          = "motion_data"
  gem.version       = MotionData::VERSION
  gem.authors       = ["Sergey Kuleshov"]
  gem.email         = ["svyatogor@gmail.com"]
  gem.description   = %q{A thin wrapper around CoreData inspired by ActiveRecord.}
  gem.summary       = %q{A thin wrapper around CoreData inspired by ActiveRecord.
                         Includes support for migrations so you don't need to open Xcode.}
  gem.homepage      = "http://svyatogor.github.com/motion_data"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features|app|db|resources)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bubble-wrap'
  gem.add_development_dependency 'motion-facon'
  gem.add_dependency 'nokogiri'
  gem.add_dependency 'activesupport'
  gem.add_dependency 'i18n'
  gem.add_dependency 'sugarcube'
end
