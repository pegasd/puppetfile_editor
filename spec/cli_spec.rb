require 'spec_helper'

stdin_puppetfile = <<~RUBY
  mod 'accounts', tag: '0.9.0', :hg => 'https://hg.mycompany.net/puppet/accounts'
  mod 'nginx', tag: '1.0.0', hg: 'https://hg.mycompany.net/puppet/nginx'
RUBY

RSpec.describe PuppetfileEditor::CLI do
  fixtures_dir = File.join(__dir__, 'fixtures')
  describe '#merge' do
    it 'works' do
      pf_cli = described_class.new(File.join(fixtures_dir, 'Puppetfile'))
      output = SpecHelper.stub_io(stdin_puppetfile) { pf_cli.merge(force: false, stdout: true) }
      expect(output).to match(/\s+accounts\s+=> updated \(tag: 0.8.0 to tag: 0.9.0\)$/)
    end
  end
end
