require 'puppetfile_editor'

module PuppetfileEditor
  # CLI methods
  class CLI
    def initialize(pfile_path)
      @pfile = PuppetfileEditor::Puppetfile.new(pfile_path)
      @pfile.load
    end

    def edit(opts)
      opts[:value] = :latest if opts[:value] == 'latest'
      @pfile.update_module(
        opts[:name],
        opts[:param],
        opts[:value],
        opts[:verbose],
      )
      @pfile.dump
    end

    def format(_)
      @pfile.dump
    end

    def add(opts)
      warn_and_exit "Module #{opts[:name]} is already present in your Puppetfile." if @pfile.modules.key? opts[:name]

      case opts[:type]
        when :hg, :git
          warn_and_exit 'URL must be provided for Git and Hg modules' unless opts.key? :url
          warn_and_exit 'Version must be provided for Git and Hg modules' unless opts.key? :param
          opts[:value] = :latest if opts[:value] == 'latest'
          @pfile.add_module(opts[:name], opts[:type] => opts[:url], opts[:param] => opts[:value])
        when :local
          @pfile.add_module(opts[:name], :local)
        when :forge
          warn_and_exit 'Version must be provided for Forge modules' unless opts.key? :version
          @pfile.add_module(opts[:name], opts[:version])
        else
          warn_and_exit 'Only hg, git, local, and forge modules are supported at the moment.'
      end
      @pfile.dump
    end

    def warn_and_exit(message)
      warn message
      exit 1
    end
  end
end
