require 'puppetfile_editor/module'

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

      @loaded = false
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

    def add_module(name, args)
      full_module_name = name.tr('/', '-')
      author, title    = (full_module_name.include? '-') ? parse_title(full_module_name) : [nil, full_module_name]

      module_hash          = {}
      module_hash[:title]  = title
      module_hash[:author] = author if author

      if args == :local
        module_hash[:type] = :local
      elsif full_module_name.include? '-'
        module_hash[:type]    = :forge
        module_hash[:version] = (args.nil?) ? :latest : args
      elsif args.is_a? Hash
        if args.has_key? :hg
          module_hash[:type]   = :hg
          module_hash[:url]    = args[:hg]
          module_hash[:branch] = args[:branch] if args[:branch]
          module_hash[:tag]    = args[:tag] if args[:tag]
          module_hash[:tag]    = args[:ref] if args[:ref]
        elsif args.has_key? :git
          module_hash[:type]   = :git
          module_hash[:url]    = args[:git]
          module_hash[:branch] = args[:branch] if args[:branch]
          module_hash[:tag]    = args[:tag] if args[:tag]
          module_hash[:ref]    = args[:ref] if args[:ref]
        end
      end


      @modules << module_hash
    end

    def parse_title(title)
      if (match = title.match(/\A(\w+)\Z/))
        [nil, match[1]]
      elsif (match = title.match(/\A(\w+)[-\/](\w+)\Z/))
        [match[1], match[2]]
      else
        raise ArgumentError, _("Module name (%{title}) must match either 'modulename' or 'owner/modulename'") % { title: title }
      end
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

    def method_missing(method, *args)
      raise NoMethodError, _("unrecognized declaration '%{method}'") % { method: method }
    end
  end

end
