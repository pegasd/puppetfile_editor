require 'puppetfile_editor/module'

module PuppetfileEditor
  # Puppetfile implementation
  class Puppetfile
    # @!attribute [r] modules
    #   @return [Array<PuppetfileEditor::Module>]
    attr_reader :modules

    # @!attribute [r] puppetfile_path
    #   @return [String] The path to the Puppetfile
    attr_reader :puppetfile_path

    # @param [String] puppetfile_path path to Puppetfile
    def initialize(puppetfile_path = nil, old_hashes = false)
      @puppetfile_path = puppetfile_path || 'Puppetfile'
      @modules         = []
      @loaded          = false
      @forge           = nil
      @old_hashes      = old_hashes
      @module_comments = {
        local: 'Local modules',
        forge: 'Modules from the Puppet Forge',
        hg:    'Mercurial modules',
        git:   'Git modules',
        undef: 'Other modules',
      }
    end

    def load
      raise StandardError, "Puppetfile #{@puppetfile_path.inspect} missing or unreadable" unless File.readable? @puppetfile_path

      dsl = PuppetfileEditor::DSL.new(self)
      dsl.instance_eval(puppetfile_contents, @puppetfile_path)
      @loaded = true
    end

    def puppetfile_contents
      File.read @puppetfile_path
    end

    def generate_puppetfile
      raise StandardError, 'File is not loaded' unless @loaded

      contents  = []
      mod_types = modules.group_by(&:type)

      contents.push "forge '#{@forge}'\n\n" if @forge
      @module_comments.each do |module_type, module_comment|
        if mod_types.has_key? module_type
          contents.push "# #{module_comment}\n"
          mod_types[module_type].sort_by(&:full_title).each do |mod|
            contents.push mod.dump(@old_hashes)
          end
          contents.push "\n"
        end
      end

      contents[0..-2].join
    end

    def dump
      File.write(@puppetfile_path, generate_puppetfile) if @loaded
    end

    # @param [String] name Module name
    # @param [String, Hash] args Module arguments
    def add_module(name, args)
      @modules.push(PuppetfileEditor::Module.new(name, args))
    end

    def update_forge_url(url)
      raise StandardError, "Forge URL must be a String, but it is a #{url.class}" unless url.is_a? String
      @forge = url
    end
  end

  # A barebones implementation of the Puppetfile DSL
  #
  # @api private
  class DSL
    def initialize(librarian)
      @librarian = librarian
    end

    def mod(name, args = nil)
      @librarian.add_module(name, args)
    end

    def forge(url)
      @librarian.update_forge_url(url)
    end

    def method_missing(method, *args)
      raise NoMethodError, "unrecognized declaration '%{method}'" % { method: method }
    end
  end
end
