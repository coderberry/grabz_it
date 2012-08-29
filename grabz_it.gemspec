# -*- encoding: utf-8 -*-
require File.expand_path('../lib/grabz_it/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eric Berry"]
  gem.email         = ["cavneb@gmail.com"]
  gem.description   = "Ruby interface to the GrabzIt (grabz.it) service"
  gem.summary       = "Ruby interface to the GrabzIt (grabz.it) service"
  gem.homepage      = "https://github.com/cavneb/grabz_it"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "grabz_it"
  gem.require_paths = ["lib"]
  gem.version       = GrabzIt::VERSION
  
  gem.add_development_dependency('rspec')
end
