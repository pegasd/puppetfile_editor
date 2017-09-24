require 'bundler/setup'
require 'puppetfile_editor'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

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
