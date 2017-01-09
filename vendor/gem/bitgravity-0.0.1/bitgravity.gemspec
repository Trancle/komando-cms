# -*- encoding: utf-8 -*-
require File.expand_path('../lib/bitgravity/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Christopher Wojno"]
  gem.email         = ["chris@wojnosystems.com"]
  gem.description   = %q{API for communicated with BitGravity to stream files and place files}
  gem.summary       = %q{API library}
  gem.homepage      = "http://www.wojnosystems.com"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "bitgravity"
  gem.require_paths = ["lib"]
  gem.version       = Bitgravity::VERSION
end
