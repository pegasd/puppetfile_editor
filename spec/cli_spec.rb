# frozen_string_literal: true

require 'spec_helper'

stdin_puppetfile = <<~RUBY
  mod 'docker', tag: '1.0.4', git: 'https://github.com/puppetlabs/puppetlabs-docker'
  mod 'apache', tag: '2.1.0', git: 'https://github.com/puppetlabs/puppetlabs-apache'
  mod 'stdlib', tag: '4.20.0', git: 'https://github.com/puppetlabs/puppetlabs-stdlib'
  mod 'ntp', tag: '7.0.0', git: 'https://github.com/puppetlabs/puppetlabs-ntp'

  mod 'accounts', tag: '0.9.0', :hg => 'https://hg.mycompany.net/puppet/accounts'
  mod 'monitoring', tag: '1.0.0', hg: 'https://hg.mycompany.net/puppet/monitoring'
  mod 'logging', tag: '0.14.0-dev1', hg: 'https://hg.mycompany.net/puppet/logging'

  mod 'puppetlabs/apt', '4.4.1'
  mod 'puppetlabs/lvm', '1.0.0'

  mod 'nginx', tag: '1.0.0', hg: 'https://hg.mycompany.net/puppet/nginx'
RUBY

RSpec.describe PuppetfileEditor::CLI do
  fixtures_dir = File.join(__dir__, 'fixtures')
  describe '#merge' do
    pf_cli = described_class.new(File.join(fixtures_dir, 'merge', 'Puppetfile'))
    output = SpecHelper.stub_io(stdin_puppetfile) { pf_cli.merge(force: false, stdout: true) }

    # Git
    it 'updates git module' do
      expect(output).to match(/docker\s+=> updated \(tag: 1.0.3 to tag: 1.0.4\)/)
    end
    it 'does nothing about a non-existant git module' do
      expect(output).to match(/apache\s+=> does not exist in source Puppetfile$/)
    end
    it 'skips over a branched git module' do
      expect(output).to match(/stdlib\s+=> kept at branch: weird_fix$/)
    end
    it 'downgrades git module with a warning' do
      expect(output).to match(/ntp\s+=> not downgrading \(tag: 7.1.0-dev1 > tag: 7.0.0\)/)
    end

    # HG
    it 'updates hg module' do
      expect(output).to match(/accounts\s+=> updated \(tag: 0.8.0 to tag: 0.9.0\)$/)
    end
    it 'updates hg module with a dev tag' do
      expect(output).to match(/logging\s+=> updated \(tag: 0.13.0 to tag: 0.14.0-dev1\)$/)
    end
    it 'skips over a hg module locked at changeset' do
      expect(output).to match(/monitoring\s+=> kept at changeset: 19ab6af$/)
    end

    # Forge
    it 'updates forge module' do
      expect(output).to match(/lvm\s+=> updated \(0.9.0 to 1.0.0\)/)
    end
    it 'downgrades forge module with a warning' do
      expect(output).to match(/apt\s+=> not downgrading \(4.5.0 > 4.4.1\)/)
    end

    # Type Mismatch
    it 'warns about a mismatched module (git vs hg)' do
      expect(output).to match(/nginx\s+=> type mismatch \('git' vs 'hg'\)$/)
    end
  end
end
