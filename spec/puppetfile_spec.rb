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
      pedit = described_class.new(File.join fixtures_dir, 'Puppetfile')
      pedit.load
      expect(pedit.modules).to be_kind_of(Array)
    end

    it 'fails when file does not exist' do
      pedit = described_class.new(File.join fixtures_dir,'nonexistant', 'Puppetfile')
      expect { pedit.load }.to raise_error(StandardError, /missing or unreadable/)
    end
  end

  describe '#generate_puppetfile' do
    it 'outputs Puppetfile' do
      pedit = described_class.new(File.join fixtures_dir, 'Puppetfile')
      pedit.load
      expect(pedit.generate_puppetfile).to eq(<<~EOS
        # Local modules
        mod 'config', :local

        # Modules from the Puppet Forge
        mod 'puppetlabs/stdlib', '4.19.0'

        # Mercurial modules
        mod 'accounts',
            hg:  'https://hg.mycompany.net/puppet-accounts',
            tag: '0.8.0'

        # Git modules
        mod 'nginx',
            git: 'https://github.com/voxpupuli/puppet-nginx',
            tag: :latest
      EOS
      )
    end

    it 'reformats Puppetfile properly' do
      pedit = described_class.new(File.join fixtures_dir, 'unformatted', 'Puppetfile')
      pedit.load
      expect(pedit.generate_puppetfile).to eq(<<~EOS
        # Local modules
        mod 'celery', :local
        mod 'check_geoip', :local
        mod 'config', :local
        mod 'kibastic', :local
        mod 'lsyncd', :local
        mod 'mongo', :local
        mod 'nginx', :local
        mod 's3cmd', :local
        mod 'vcsrepo', :local
        mod 'vpn', :local

        # Modules from the Puppet Forge
        mod 'puppetlabs/concat', '4.0.1'
        mod 'puppetlabs/stdlib', '4.17.1'
        mod 'puppetlabs/lvm', '0.7.0'
        mod 'puppetlabs/inifile', '1.4.3'
        mod 'puppetlabs/apache', '1.10.0'
        mod 'puppetlabs/postgresql', '5.0.0'
        mod 'puppetlabs/rabbitmq', '5.6.0'
        mod 'locp/cassandra', '1.13.0'
        mod 'wywygmbh/fluentd', '0.5.0'
        mod 'camptocamp/kmod', '2.1.0'
        mod 'petems/swap_file', '3.0.2'
        mod 'KyleAnderson/consul', '2.1.0'
      EOS
      )
    end
  end

  it 'properly fails when parsing broken Puppetfile' do
    pedit = described_class.new(File.join fixtures_dir, 'broken', 'Puppetfile')
    expect { pedit.load }
      .to raise_error(NoMethodError, /unrecognized declaration 'omg'/)
  end
end
