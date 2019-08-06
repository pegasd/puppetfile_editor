# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
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
  spec.license       = 'MIT'
  spec.files         = Dir['lib/**/*.rb', 'bin/pfile', 'README.md', 'CHANGELOG.md']
  spec.bindir        = 'bin'
  spec.executables   = 'pfile'
  spec.require_paths = ['lib']
  spec.description   = <<-DESCRIPTION
    PuppetfileEditor provides an easy-to-use interface to check Puppetfile for validity,
    update module versions, add, and remove modules.
  DESCRIPTION

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
