require 'spec_helper'

stdin_puppetfile = <<~RUBY
  mod 'accounts', tag: '0.9.0', :hg => 'https://hg.mycompany.net/puppet/accounts'
  mod 'apache', tag: '2.1.0', git: 'https://github.com/puppetlabs/puppetlabs-apache'
  mod 'monitoring', tag: '1.0.0', hg: 'https://hg.mycompany.net/puppet/monitoring'
  mod 'nginx', tag: '1.0.0', hg: 'https://hg.mycompany.net/puppet/nginx'
  mod 'stdlib', tag: '4.20.0', git: 'https://github.com/puppetlabs/puppetlabs-stdlib'
RUBY

RSpec.describe PuppetfileEditor::CLI do
  fixtures_dir = File.join(__dir__, 'fixtures')
  describe '#merge' do
    it 'works' do
      pf_cli = described_class.new(File.join(fixtures_dir, 'merge', 'Puppetfile'))
      output = SpecHelper.stub_io(stdin_puppetfile) { pf_cli.merge(force: false, stdout: true) }
      expect(output).to match(/accounts\s+=> updated \(tag: 0.8.0 to tag: 0.9.0\)$/)
      expect(output).to match(/apache\s+=> does not exist in source Puppetfile$/)
      expect(output).to match(/monitoring\s+=> kept at changeset: 19ab6af$/)
      expect(output).to match(/nginx\s+=> type mismatch \('git' vs 'hg'\)$/)
      expect(output).to match(/stdlib\s+=> kept at branch: weird_fix$/)
    end
  end
end
