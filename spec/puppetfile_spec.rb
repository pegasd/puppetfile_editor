# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PuppetfileEditor::Puppetfile do
  fixtures_dir = File.join(__dir__, 'fixtures')

  describe '#initialize' do
    it 'passes initialization' do
      expect(described_class.new).to be_a_kind_of(PuppetfileEditor::Puppetfile)
    end
  end

  describe '#load' do
    it 'loads basic Puppetfile' do
      pf = described_class.new(File.join(fixtures_dir, 'Puppetfile'))
      pf.load
      expect(pf.modules.size).to eq(6)
    end

    it 'loads Puppetfile from contents' do
      pf = described_class.new('', false, <<~RUBY
        mod 'nginx',
            git: 'https://github.com/voxpupuli/puppet-nginx',
            tag: '0.7.1'
      RUBY
    )
      pf.load
      expect(pf.modules.size).to eq(1)
    end

    it 'fails on broken contents' do
      pf = described_class.new('', false, <<~RUBY
        nod 'nginx',
            git: 'https://github.com/voxpupuli/puppet-nginx',
            tag: '0.7.1'
      RUBY
    )
      expect { pf.load }.to raise_error(NoMethodError, /Unrecognized declaration: 'nod'/)
    end

    it 'fails when file does not exist' do
      pf = described_class.new(File.join(fixtures_dir, 'nonexistant', 'Puppetfile'))
      expect { pf.load }.to raise_error(StandardError, /missing or unreadable/)
    end

    it 'fails when Puppetfile is broken' do
      pf = described_class.new(File.join(fixtures_dir, 'broken', 'Puppetfile'))
      expect { pf.load }
        .to raise_error(NoMethodError, /Unrecognized declaration: 'omg'/)
    end
  end

  describe '#generate_puppetfile' do
    it 'outputs Puppetfile' do
      pf = described_class.new(File.join(fixtures_dir, 'Puppetfile'))
      pf.load
      expect(pf.generate_puppetfile).to eq(<<~RUBY
        # Local modules
        mod 'config', :local

        # Modules from the Puppet Forge
        mod 'puppetlabs/stdlib', '4.19.0'

        # Mercurial modules
        mod 'accounts',
            hg:  'https://hg.mycompany.net/puppet/accounts',
            tag: '0.8.0'
        mod 'apache',
            hg:     'https://hg.mycompany.net/puppet/apache',
            branch: 'crazy_fix'

        # Git modules
        mod 'mcollective',
            git:    'https://github.com/voxpupuli/puppet-mcollective',
            branch: 'puppet3'
        mod 'nginx',
            git: 'https://github.com/voxpupuli/puppet-nginx',
            tag: :latest
      RUBY
                                          )
    end

    it 'reformats Puppetfile properly' do
      pf = described_class.new(File.join(fixtures_dir, 'unformatted', 'Puppetfile'))
      pf.load
      expect(pf.generate_puppetfile).to eq(<<~RUBY
        # Local modules
        mod 'celery', :local
        mod 'check_geoip', :local
        mod 'config', :local
        mod 'kibastic', :local
        mod 'lsyncd', :local
        mod 'mongo', :local
        mod 's3cmd', :local
        mod 'vcsrepo', :local
        mod 'vpn', :local

        # Modules from the Puppet Forge
        mod 'puppetlabs/apache', '1.10.0'
        mod 'locp/cassandra', '1.13.0'
        mod 'puppetlabs/concat', '4.0.1'
        mod 'KyleAnderson/consul', '2.1.0'
        mod 'wywygmbh/fluentd', '0.5.0'
        mod 'puppetlabs/inifile', '1.4.3'
        mod 'camptocamp/kmod', '2.1.0'
        mod 'puppetlabs/lvm', '0.7.0'
        mod 'puppetlabs/postgresql', '5.0.0'
        mod 'puppetlabs/rabbitmq', '5.6.0'
        mod 'puppetlabs/stdlib', '4.17.1'
        mod 'petems/swap_file', '3.0.2'

        # Git modules
        mod 'nginx',
            git: 'https://github.com/voxpupuli/puppet-nginx',
            tag: :latest
      RUBY
                                          )
    end
  end

  describe '#update_module' do
    pf = described_class.new(File.join(fixtures_dir, 'Puppetfile'))
    pf.load
    it 'updates git module tag' do
      pf.update_module('nginx', 'tag', '1.2')
      expect(pf.modules['nginx'].params[:tag]).to eq('1.2')
    end

    it 'updates hg module tag' do
      pf.update_module('accounts', 'tag', '0.9.0')
      expect(pf.modules['accounts'].params[:tag]).to eq('0.9.0')
    end

    it 'force overrides branch with tag for hg module' do
      pf.update_module('apache', 'tag', '0.9.0')
      expect(pf.modules['apache'].params[:tag]).to eq('0.9.0')
    end

    it 'force overrides branch with tag for git module' do
      pf.update_module('mcollective', 'tag', 'v2.5.0')
      expect(pf.modules['mcollective'].params[:tag]).to eq('v2.5.0')
    end

    it 'updates forge module version' do
      pf.update_module('stdlib', 'version', '4.20.0')
      expect(pf.modules['stdlib'].params[:version]).to eq('4.20.0')
    end
  end

  describe '#compare_with' do
    it 'compares two Puppetfiles' do
      pf = described_class.new(File.join(fixtures_dir, 'compare', 'source.Puppetfile'))
      pf.load

      pf_new = described_class.new(File.join(fixtures_dir, 'compare', 'new.Puppetfile'))
      pf_new.load

      expect(pf.compare_with(pf_new)).to eq(
        'apache'   => { old: '2.0.0', new: '2.1.0', type: :git },
        'apt'      => { old: '4.1.0', new: '4.3.0', type: :forge },
        'nginx'    => { old: '0.7.0', new: '0.7.1', type: :git },
        'rabbitmq' => { new: '7.0.0', type: :git },
      )
    end

    it 'compares two Puppetfiles with modules of different types' do
      pf = described_class.new(File.join(fixtures_dir, 'compare', 'source.Puppetfile'))
      pf.load

      pf_new = described_class.new(File.join(fixtures_dir, 'compare', 'new_different_types.Puppetfile'))
      pf_new.load

      expect(pf.compare_with(pf_new, compare_across_types: true)).to eq(
        'apache'   => { old: '2.0.0', new: '2.1.0', type: :hg },
        'apt'      => { old: '4.1.0', new: '4.3.0', type: :forge },
        'nginx'    => { old: '0.7.0', new: '0.7.1', type: :git },
        'rabbitmq' => { new: '7.0.0', type: :git },
      )
    end
  end
end
