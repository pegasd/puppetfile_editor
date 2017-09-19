lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'puppetfile_editor/version'

Gem::Specification.new do |spec|
  spec.name     = 'puppetfile_editor'
  spec.version  = PuppetfileEditor::VERSION
  spec.platform = Gem::Platform::RUBY

  spec.authors       = 'Eugene Piven'
  spec.email         = 'epiven@gmail.com'
  spec.homepage      = 'https://github.com/pegasd/puppetfile_editor'
  spec.summary       = 'Parse and edit Puppetfile'
  spec.description   = <<-DESCRIPTION
    PuppetfileEditor provides an easy-to-use interface to check Puppetfile for validity,
    update module versions, add, and remove modules.
  DESCRIPTION
  spec.license       = 'MIT'
  spec.files         = Dir['README.md', 'lib/**/*.rb', 'bin/pfile']
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
