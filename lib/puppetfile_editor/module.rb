module PuppetfileEditor
  class Module
    attr_reader :type
    attr_reader :params
    attr_reader :name
    attr_reader :message
    attr_reader :status

    def initialize(title, args = nil)
      @type    = :undef
      @params  = nil
      @message = nil
      @status  = nil
      if args == :local
        @type = :local
      elsif args.nil? || args.is_a?(String) || args.is_a?(Symbol)
        @type   = :forge
        @params = { version: args } unless args.nil?
      elsif args.is_a? Hash
        if args.key? :hg
          @type = :hg
        elsif args.key? :git
          @type = :git
        end
        @params = args
        calculate_indent
      end
      @author, @name = parse_title title
    end

    def set(param, newvalue, force = false)
      case @type
        when :hg, :git
          if !force && !([:branch, :ref, :changeset] & @params.keys).empty?
            set_message("kept at (#{full_version})", :wont_upgrade)
          elsif !%w[branch tag ref changeset].include? param
            set_message("only 'branch', 'tag', 'ref', and 'changeset' are supported for '#{@type}' modules.", :unsupported)
          else
            set_message("updated (#{full_version} to #{param}: #{newvalue}", :updated)
            @params.delete :branch
            @params.delete :tag
            @params.delete :ref
            @params.delete :changeset
            @params[param.to_sym] = newvalue
            calculate_indent
          end
        when :forge
          if param == 'version'
            @params[:version] = newvalue
            set_message("successfully set #{param} to #{newvalue} for #{@name}.", :updated)
          else
            set_message("only 'version' is supported for forge modules.", :unsupported)
          end
        else
          set_message("editing params for '#{@type}' modules is not supported.", :unsupported)
      end
    end

    def merge_with(mod, force = false)
      unless mod.type == @type
        set_message("type mismatch ('#{@type}' vs '#{mod.type}')", :type_mismatched)
        return
      end
      case @type
        when :hg, :git
          new = mod.params.reject { |param, _| param.eql? @type }
          if !force && new.keys == [:tag] && !([:branch, :ref, :changeset] & @params.keys).empty?
            set_message("kept at #{full_version}", :wont_upgrade)
            return
          end
          if full_version == mod.full_version
            set_message("versions match (#{full_version})", :matched)
            return
          else
            set_message("updated (#{full_version} to #{mod.full_version})", :updated)
          end
          @params.delete_if { |param, _| [:branch, :tag, :ref, :changeset].include? param }
          @params.merge!(new)
          calculate_indent
        when :forge
          unless force
            if mod.params.nil? || mod.params.is_a?(Symbol)
              set_message("won't upgrade to #{mod.full_version}", :wont_upgrade)
              return
            end
          end
          if full_version == mod.full_version
            set_message("versions match (#{full_version})", :matched)
            return
          else
            set_message("updated (#{full_version} to #{mod.full_version})", :updated)
          end
          @params = mod.params
        else
          set_message('only git, forge, and hg modules are supported for merging', :skipped)
      end
    end

    def dump
      output = []
      case @type
        when :hg, :git
          output.push "mod '#{full_title}'"
          @params.each do |param_name, param_value|
            value = if param_value == :latest
              ':latest'
            else
              "'#{param_value}'"
            end
            param = "#{param_name}:".ljust(@indent)
            output.push "    #{param} #{value}"
          end
        when :local
          output.push("mod '#{full_title}', :local")
        else
          if @params.nil?
            output.push("mod '#{full_title}'")
          else
            output.push("mod '#{full_title}', '#{@params[:version]}'")
          end
      end
      output.join(",\n")
    end

    def full_title
      return "#{@author}/#{@name}" if @author
      @name
    end

    def full_version
      case @type
        when :hg, :git
          @params.reject { |param, _| param.eql? @type }.map { |param, value| "#{param}: #{value}" }.sort.join(', ')
        when :forge
          return @params[:version] if @params.key? :version
          nil
      end
    end

    def set_message(message, status)
      @message = message
      @status  = status
    end

    private

    def parse_title(title)
      if (match = title.match(/^(\w+)$/))
        [nil, match[1]]
      elsif (match = title.match(%r{^(\w+)[/-](\w[\w-]*\w)$}))
        [match[1], match[2]]
      else
        raise ArgumentError, "Module name (#{title}) must match either 'modulename' or 'owner/modulename'"
      end
    end

    def calculate_indent
      @indent = @params.keys.max_by(&:length).length + 1
    end
  end
end
