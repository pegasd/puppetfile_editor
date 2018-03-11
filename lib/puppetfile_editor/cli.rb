# frozen_string_literal: true

require 'puppetfile_editor'

module PuppetfileEditor
  # CLI methods
  class CLI
    def initialize(pfile_path)
      @pfile  = PuppetfileEditor::Puppetfile.new(pfile_path)
      @logger = PuppetfileEditor::Logging.new
      begin
        @pfile.load
      rescue IOError, NoMethodError => e
        @logger.log_and_exit(e.message)
      rescue StandardError => e
        @logger.log_and_exit(e.message)
      end
    end

    def edit(opts)
      opts[:value] = :latest if opts[:value] == 'latest'
      @logger.log_and_exit('Please specify module name') unless opts[:name].is_a?(String)
      @logger.log_and_exit('Please specify version') unless opts[:version].is_a?(String)
      if (match = opts[:version].match(/^(\w+)=([^=]+)$/))
        param = match[1]
        value = match[2]
      else
        @logger.log_and_exit('Version must match PARAM=VALUE pattern')
      end
      begin
        @pfile.update_module(opts[:name], param, value)
      rescue StandardError => e
        @logger.log_and_exit(e.message)
      end
      @pfile.dump
    end

    def format(_why_am_i_here)
      @pfile.dump
    end

    def delete(opts)
      warn_and_exit "Module #{opts[:name]} does not exist in your Puppetfile." unless @pfile.modules.key? opts[:name]

      @pfile.delete_module(opts[:name])
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

    def merge(opts)
      @pfdata = PuppetfileEditor::Puppetfile.new(nil, true)
      begin
        @pfdata.load
      rescue SyntaxError
        @logger.log_and_exit('Format error.')
      end
      new_mod_types = @pfdata.modules.values.group_by(&:type)
      new_mod_types.each do |mod_type, mods|
        puts "\n   #{@pfile.module_sections[mod_type]}\n\n"
        unless [:hg, :git, :forge].include? mod_type
          puts " Skipping #{mod_type} section."
          next
        end
        indent = mods.map(&:name).max_by(&:length).length
        mods.each do |mod|
          if @pfile.modules.key? mod.name
            @pfile.modules[mod.name].merge_with(mod, opts[:force])
            @logger.mod_message(@pfile.modules[mod.name], indent)
          else
            mod.set_message('does not exist in source Puppetfile', :not_found)
            @logger.mod_message(mod, indent)
          end
        end
      end
      if opts[:stdout]
        $stdout.puts(@pfile.generate_puppetfile)
      else
        @pfile.dump
      end
    end

    def warn_and_exit(message)
      warn message
      exit 1
    end
  end

  # Abstraction of logging methods for PuppetfileEditor::CLI
  #
  # @api private
  class Logging
    def initialize
      @statuses = {
        updated:         "[ \e[32;1m+\e[0m ]",
        matched:         "[ \e[0;1m=\e[0m ]",
        skipped:         "[ \e[33;1m~\e[0m ]",
        not_found:       "[ \e[31;1mx\e[0m ]",
        type_mismatched: "[ \e[31;1mx\e[0m ]",
        wont_upgrade:    "[ \e[33;1m!\e[0m ]",
        downgrade:       "[ \e[31;1m!\e[0m ]",
        warn:            "[ \e[31;1m!!\e[0m ]",
        undef:           '',
      }
    end

    def log(message, message_type = :undef)
      status = if @statuses.key? message_type
                 @statuses[message_type]
               else
                 @statuses[:undef]
               end
      puts "#{status} #{message}"
    end

    def log_and_exit(message)
      log(message, :warn)
      exit 1
    end

    def mod_message(mod, indent)
      log("#{mod.name.ljust(indent)} => #{mod.message}", mod.status)
    end
  end
end
