
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pseudolocalization/version"

Gem::Specification.new do |spec|
  spec.name          = "pseudolocalization"
  spec.version       = Pseudolocalization::VERSION
  spec.authors       = ["Christian Blais"]
  spec.email         = ["christ.blais@gmail.com"]
  spec.licenses      = ['MIT']

  spec.summary       = %q{Internationalization development tool}
  spec.description   = %q{Internationalization development tool to help identify missing translations}
  spec.homepage      = "https://github.com/Shopify/pseudolocalization"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
