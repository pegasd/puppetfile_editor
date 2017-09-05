require 'spec_helper'

RSpec.describe PuppetfileEditor do
  it 'has a version number' do
    expect(PuppetfileEditor::VERSION).not_to be nil
  end

  it 'passes initialization' do
    expect(PuppetfileEditor::Puppetfile.new).to be_a_kind_of(PuppetfileEditor::Puppetfile)
  end

  it 'parses test Puppetfile' do
    pedit = PuppetfileEditor
  end
end
