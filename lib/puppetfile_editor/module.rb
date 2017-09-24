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
          if %w[branch tag ref].include? param
            @params.delete :branch
            @params.delete :tag
            @params.delete :ref
            @params[param.to_sym] = newvalue
            calculate_indent
          else
            raise StandardError, "Only 'branch', 'tag', and 'ref' are supported for '#{@type}' modules."
          end
        when :forge
          if param == 'version'
            @params[:version] = newvalue
          else
            raise StandardError, "Only 'version' is supported for forge modules."
          end
        else
          raise StandardError, "Editing params for '#{@type}' modules is not supported."
      end
    end

    def merge_with(mod, force = false)
      unless mod.type == @type
        @status = :type_mismatched
        raise(StandardError, "type mismatch ('#{@type}' vs '#{mod.type}')")
      end
      case @type
        when :hg, :git
          new = mod.params.reject { |param, _| param.eql? @type }
          if !force && new.keys == [:tag] && (@params.key?(:branch) || @params.key?(:ref))
            raise(StandardError, "kept at #{full_version}")
          end
          if full_version == mod.full_version
            @message = "versions match (#{full_version})"
            @status  = :matched
          else
            @message = "updated (#{full_version} to #{mod.full_version})"
            @status  = :updated
          end
          @params.delete_if { |param, _| [:branch, :tag, :ref].include? param }
          @params.merge!(new)
          calculate_indent
        when :forge
          unless force
            if mod.params.nil? or mod.params.is_a? Symbol
              @status = :wont_upgrade
              raise(StandardError, "won't upgrade to #{mod.full_version}")
            end
          end
          if full_version == mod.full_version
            @message = "versions match (#{full_version})"
            @status  = :matched
          else
            @message = "updated (#{full_version} to #{mod.full_version})"
            @status  = :updated
          end
          @params = mod.params
        else
          @status = :skipped
          raise(StandardError, 'only git, forge, and hg modules are supported for merging')
      end
    end

    def dump(old_hashes = false)
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
            param = old_hashes ? ":#{param_name.to_s.ljust(@indent - 1)} =>" : "#{param_name}:".ljust(@indent)
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
        else
          nil
      end
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
