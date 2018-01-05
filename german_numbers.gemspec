
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "german_numbers/version"

Gem::Specification.new do |spec|
  spec.name          = "german_numbers"
  spec.version       = GermanNumbers::VERSION
  spec.authors       = ["Gleb Sinyavsky"]
  spec.email         = ["zhulik.gleb@gmail.com"]

  spec.summary       = %q{Gem for converting numbers to german words and vise-versa.}
  spec.description   = %q{Gem for converting numbers to german words and vise-versa.}
  spec.homepage      = "https://github.com/zhulik/german_words"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
