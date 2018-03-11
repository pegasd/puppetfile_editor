# frozen_string_literal: true

require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
require 'puppetfile_editor'

# Various spec helper methods
class SpecHelper
  # Substitute fake IO class
  def self.stub_io(in_str)
    old_stdin  = $stdin
    old_stdout = $stdout
    $stdin     = StringIO.new(in_str)
    $stdout    = StringIO.new
    yield
    $stdout.string
  ensure
    $stdin  = old_stdin
    $stdout = old_stdout
  end
end
