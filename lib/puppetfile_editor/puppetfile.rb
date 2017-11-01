# frozen_string_literal: true

require 'puppetfile_editor/module'

module PuppetfileEditor
  # Puppetfile implementation
  class Puppetfile
    # @!attribute [r] modules
    #   @return [Hash<String, PuppetfileEditor::Module>]
    attr_reader :modules

    # @!attribute [r] puppetfile_path
    #   @return [String] The path to the Puppetfile
    attr_reader :puppetfile_path

    attr_reader :module_sections

    # @param [String] path path to Puppetfile
    def initialize(path = 'Puppetfile', from_stdin = false, contents = nil)
      @puppetfile_path = path
      @from_stdin      = from_stdin
      @contents        = contents
      @modules         = {}
      @loaded          = false
      @forge           = nil

      @module_sections = {
        local: 'Local modules',
        forge: 'Modules from the Puppet Forge',
        hg:    'Mercurial modules',
        git:   'Git modules',
        undef: 'Other modules',
      }
    end

    def load
      puppetfile_contents = if @from_stdin
                              $stdin.gets(nil).chomp
                            elsif @contents
                              @contents
                            else
                              raise(IOError, "'#{@puppetfile_path}' is missing or unreadable") unless File.readable?(@puppetfile_path)
                              File.read @puppetfile_path
                            end

      dsl = PuppetfileEditor::DSL.new(self)
      dsl.instance_eval(puppetfile_contents)
      @loaded = true
    end

    def generate_puppetfile
      raise StandardError, 'File is not loaded' unless @loaded

      contents = []

      contents.push "forge '#{@forge}'\n" if @forge

      @module_sections.each do |module_type, module_comment|
        module_list = modules.select { |_, mod| mod.type == module_type }
        next unless module_list.any?
        contents.push "# #{module_comment}"
        module_list.values.sort_by(&:name).each do |mod|
          contents.push mod.dump
        end
        contents.push ''
      end

      contents.join("\n")
    end

    def dump
      File.write(@puppetfile_path, generate_puppetfile) if @loaded
    end

    def update_module(name, param, value)
      raise StandardError, "Module #{name} does not exist in your Puppetfile" unless @modules.key? name

      @modules[name].set(param, value, true)
    end

    def compare_with(pf)
      diff = {}
      pf.modules.each do |mod_name, mod|
        next unless [:git, :hg, :forge].include? mod.type
        version_key = mod.type == :forge ? :version : :tag

        unless @modules.key? mod_name
          if mod.params.key?(version_key)
            diff[mod_name] = { new: mod.params[version_key], type: mod.type }
          end
          next
        end

        local_mod = @modules[mod_name]

        next unless mod.type == local_mod.type
        next unless mod.params.key?(version_key) && local_mod.params.key?(version_key)
        next if mod.params[version_key] == local_mod.params[version_key]
        diff[mod_name] = { old: local_mod.params[version_key], new: mod.params[version_key], type: mod.type }
      end
      diff
    end

    # @param [String] name Module name
    # @param [String, Hash] args Module arguments
    def add_module(name, args)
      mod                = PuppetfileEditor::Module.new(name, args)
      @modules[mod.name] = mod
    end

    def delete_module(name)
      @modules.delete(name)
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

    def method_missing(method, *_)
      raise NoMethodError, "Unrecognized declaration: '#{method}'"
    end
  end
end
