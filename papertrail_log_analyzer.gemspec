# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'papertrail_log_analyzer/version'

Gem::Specification.new do |spec|
  spec.name          = "papertrail_log_analyzer"
  spec.version       = PapertrailLogAnalyzer::VERSION
  spec.authors       = ["Eric Faerber"]
  spec.email         = ["eric@masteryconnect.com"]
  spec.description   = %q{Analyzes log files from papertrail and reports timings}
  spec.summary       = %q{Analyzes log files from papertrail}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
