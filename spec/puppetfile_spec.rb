require 'spec_helper'

RSpec.describe PuppetfileEditor::Puppetfile do
  it 'passes initialization' do
    expect(described_class.new).to be_a_kind_of(PuppetfileEditor::Puppetfile)
  end

  it 'parses test Puppetfile' do
    pedit = described_class.new('spec/fixtures/Puppetfile')
    pedit.load
    expect(pedit.modules).to be_kind_of(Array)
  end

  it 'outputs Puppetfile' do
    pedit = described_class.new('spec/fixtures/Puppetfile')
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

  it 'properly fails when parsing broken Puppetfile' do
    pedit = described_class.new('spec/fixtures/broken_Puppetfile')
    expect { pedit.load }
      .to raise_error(NoMethodError, /unrecognized declaration 'omg'/)
  end
end
