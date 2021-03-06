
Gem::Specification.new do |spec|
  spec.name          = "embulk-input-travis"
  spec.version       = "0.6.0"
  spec.authors       = [""]
  spec.summary       = "Travis input plugin for Embulk"
  spec.description   = "Loads records from Travis."
  spec.email         = [""]
  spec.licenses      = ["MIT"]
  # TODO set this: spec.homepage      = "https://github.com//embulk-input-travis"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'travis'

  spec.add_development_dependency 'bundler', ['>= 1.10.6']
  spec.add_development_dependency 'rake', ['>= 10.0']
  spec.add_development_dependency 'pry'
end
