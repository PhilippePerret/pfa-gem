require_relative 'lib/pfa/version'

Gem::Specification.new do |s|
  s.name          = "pfa"
  s.version       = PFA::VERSION
  s.authors       = ["PhilippePerret"]
  s.email         = ["philippe.perret@yahoo.fr"]

  s.summary       = %q{Gestion d'un Paradigme de Field Augmentée (Field Augmented Paradigm)}
  s.description   = %q{Gestion complète d'un PFA, pour le produire soit en HTML soit en PDF et calculer les différences entre PFA relatif et PFA absolu.}
  s.homepage      = "https://rubygems.org/gems/pfa"
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  s.metadata["allowed_push_host"] = "https://rubygems.org"

  s.add_dependency 'clir'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-color'

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = "https://github.com/PhilippePerret/pfa"
  s.metadata["changelog_uri"] = "https://github.com/PhilippePerret/pfa/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
  end
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
