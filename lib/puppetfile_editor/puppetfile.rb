module PuppetfileEditor

  class Puppetfile
    # @!attribute [r] modules
    #   @return [Array<PuppetfileEditor::Module>]
    attr_reader :modules

    # @!attrbute [r] puppetfile_path
    #   @return [String] The path to the Puppetfile
    attr_reader :puppetfile_path

    # @param [String] puppetfile_path path to Puppetfile
    def initialize(puppetfile_path = nil)
      @puppetfile_path = puppetfile_path || 'Puppetfile'
      @modules         = []
      @loaded          = false
      @indents         = {
        local: 0,
        forge: 0,
      }
      @module_comments = {
        local: 'Local modules',
        forge: 'Modules from the Puppet Forge',
        hg:    'Mercurial modules',
        git:   'Git modules',
        undef: 'Other modules',
      }
    end

    def load
      if File.readable? @puppetfile_path
        load!
      else
        logger.debug _("Puppetfile %{path} missing or unreadable") % { path: @puppetfile_path.inspect }
      end
    end

    def load!
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
      mod_types = modules.group_by { |mod| mod.type }

      @module_comments.each do |module_type, module_comment|
        if mod_types.has_key? module_type
          contents.push "# #{module_comment}\n"
          mod_types[module_type].each do |mod|
            contents.push mod.dump
          end
          contents.push "\n"
        end
      end

      contents[0..-2].join
    end

    # @param [String] name Module name
    # @param [String, Hash] args Module arguments
    def add_module(name, args)
      @modules.push(PuppetfileEditor::Module.new(name, args))
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

    def method_missing(method, *args)
      raise NoMethodError, "unrecognized declaration '%{method}'" % { method: method }
    end
  end

end
