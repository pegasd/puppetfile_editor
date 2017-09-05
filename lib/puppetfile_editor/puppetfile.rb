require 'puppetfile_editor/module'

module PuppetfileEditor

  class Puppetfile
    # @!attribute [r] modules
    #   @return [Array<PuppetfileEditor::Module>]
    attr_reader :modules

    # @!attrbute [r] puppetfile_path
    #   @return [String] The path to the Puppetfile
    attr_reader :puppetfile_path

    def initialize(puppetfile_path: nil)
      @puppetfile_path = puppetfile_path || 'Puppetfile'

      @loaded = false
    end

    def load
      if File.readable? @puppetfile_path
        self.load!
      else
        logger.debug _("Puppetfile %{path} missing or unreadable") % { path: @puppetfile_path.inspect }
      end
    end

    def load!
      dsl = PuppetfileEditor::DSL.new(self)
      dsl.instance_eval(puppetfile_contents, @puppetfile_path)
    end

    def puppetfile_contents
      File.read @puppetfile_path
    end
  end

  class DSL
    # A barebones implementation of the Puppetfile DSL
    #
    # @api private

    def initialize(librarian)
      @librarian = librarian
    end

    def mod(name, args = nil)
      @librarian.add_module(name, args)
    end

    def forge(location)
      @librarian.set_forge(location)
    end

    def moduledir(location)
      @librarian.set_moduledir(location)
    end

    def method_missing(method, *args)
      raise NoMethodError, _("unrecognized declaration '%{method}'") % {method: method}
    end
  end

end
