# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nexus_artifact/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David McCullars"]
  gem.email         = ["david.mccullars@gmail.com"]
  gem.description   = %q{Simple Ruby gem to download/publish arbitrary binary file from/to Nexus server}
  gem.summary       = %q{Simple Ruby gem to download/publish arbitrary binary file from/to Nexus server}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "nexus_artifact"
  gem.require_paths = ["lib"]
  gem.version       = NexusArtifact::VERSION
end
