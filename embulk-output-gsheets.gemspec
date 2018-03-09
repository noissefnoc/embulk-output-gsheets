
Gem::Specification.new do |spec|
  spec.name          = 'embulk-output-gsheets'
  spec.version       = '0.1.0'
  spec.authors       = ['noissefnoc']
  spec.summary       = 'Google Sheets output plugin for Embulk'
  spec.description   = 'Dumps records to Google Sheets.'
  spec.email         = ['noissefnoc@gmail.com']
  spec.licenses      = ['MIT']
  spec.homepage      = 'https://github.com/noissefnoc/embulk-output-gsheets'

  spec.files         = `git ls-files`.split("\n") + Dir['classpath/*.jar']
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'google-api-client', ['~> 0.11']

  spec.add_development_dependency 'bundler', ['>= 1.10.6']
  spec.add_development_dependency 'rake', ['>= 10.0']
end
