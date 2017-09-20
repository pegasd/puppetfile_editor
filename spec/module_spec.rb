require 'spec_helper'
require 'puppetfile_editor/module'

RSpec.describe PuppetfileEditor::Module do
  describe '#initialize' do
    it 'can initialize forge modules' do
      expect(described_class.new('puppetlabs/stdlib', '4.20.0').type).to eq(:forge)
      expect(described_class.new('puppetlabs/stdlib', '4.20.0').params[:version]).to eq('4.20.0')

      expect(described_class.new('puppetlabs/stdlib', :latest).type).to eq(:forge)
      expect(described_class.new('puppetlabs/stdlib', :latest).params[:version]).to eq(:latest)

      expect(described_class.new('puppetlabs/stdlib').type).to eq(:forge)
    end

    it 'can initialize local modules' do
      expect(described_class.new('accounts', :local).type).to eq(:local)
      expect(described_class.new('role', :local).type).to eq(:local)
    end

    it 'can initialize git modules' do
      expect(described_class.new('apt', git: 'https://github.com/puppetlabs/puppetlabs-apt', tag: '4.1.0').type).to eq(:git)
      expect(described_class.new('apt', git: 'https://github.com/puppetlabs/puppetlabs-apt', tag: '4.1.0').params).to eq(
        git: 'https://github.com/puppetlabs/puppetlabs-apt',
        tag: '4.1.0',
      )
    end

    it 'can initialize hg module' do
      expect(described_class.new('accounts', hg: 'https://hg.mycompany.net/puppet/accounts', tag: '0.10.0').type).to eq(:hg)
    end

    it 'can initialize unsupported module' do
      expect(described_class.new('weird_module', %w[hello there]).type).to eq(:undef)
    end
  end

  describe '#set' do
    it 'can update tag of git module' do
      m = described_class.new('apt', git: 'https://github.com/puppetlabs/puppetlabs-apt', tag: '4.1.0')
      m.set('tag', '4.2.0')
      expect(m.params[:tag]).to eq('4.2.0')
    end

    it 'can rewrite tag with branch for hg module' do
      m = described_class.new('accounts', hg: 'https://hg.mycompany.net/puppet/accounts', tag: '0.10.0')
      m.set('branch', 'default')
      expect(m.params[:tag]).to be_nil
      expect(m.params[:branch]).to eq('default')
    end

    it 'can update forge module version' do
      m = described_class.new('KyleAnderson/consul', '2.1.0')
      m.set('version', '2.2.0')
      expect(m.params[:version]).to eq('2.2.0')
    end
  end

  describe '#dump' do
    it 'can dump git module' do
      m = described_class.new('apt', git: 'https://github.com/puppetlabs/puppetlabs-apt', branch: 'master')
      expect(m.dump).to eq(<<~RUBY.chop!
        mod 'apt',
            git:    'https://github.com/puppetlabs/puppetlabs-apt',
            branch: 'master'
      RUBY
      )
    end
  end
end
