require_relative 'lib/rich_enums/version'

Gem::Specification.new do |spec|
  spec.name          = 'rich_enums'
  spec.version       = RichEnums::VERSION
  spec.authors       = %w[harunkumars rtdp]
  spec.email         = %w[harun@betacraft.io rtdp@betacraft.io]

  spec.summary       = 'When a simple name to value mapping is not enough'
  spec.description   = <<-DESC
With Enums we are able to map a label to a value on the database. 
Use Rich Enum if you need to maintain an additional mapping at the point of enum definition, 
for e.g. for presentation purposes or for mapping to a different value on a different system.
DESC
  spec.homepage      = 'https://github.com/betacraft/rich_enums'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/betacraft/rich_enums'
  spec.metadata['changelog_uri'] = 'https://github.com/betacraft/rich_enums/README.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
