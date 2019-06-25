# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'german_numbers/version'

Gem::Specification.new do |spec|
  spec.name          = 'german_numbers'
  spec.version       = GermanNumbers::VERSION
  spec.authors       = ['Gleb Sinyavsky']
  spec.email         = ['zhulik.gleb@gmail.com']

  spec.summary       = 'Gem for converting numbers to german words and vise-versa.'
  spec.description   = 'Gem for converting numbers to german words and vise-versa.'
  spec.homepage      = 'https://github.com/zhulik/german_words'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'sorbet-runtime'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'ruby-prof'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sorbet'
end
