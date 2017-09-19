module PuppetfileEditor
  class Module
    attr_reader :type
    attr_reader :params

    def initialize(title, args = nil)
      @type   = :undef
      @params = nil
      if args == :local
        @type = :local
      elsif args.nil? or args.is_a? String or args.is_a? Symbol
        @type   = :forge
        @params = { version: args } unless args.nil?
      elsif args.is_a? Hash
        if args.has_key? :hg
          @type = :hg
        elsif args.has_key? :git
          @type = :git
        end
        @params = args
        calculate_indent
      end
      @author, @name = parse_title title
    end

    def set(param, newvalue)
      case @type
        when :hg, :git
          if %w{branch tag ref}.include? param
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
            param = old_hashes ? ":#{param_name.to_s.ljust(@indent - 1)} =>" : "#{param_name.to_s}:".ljust(@indent)
            output.push '    %{param} %{value}' % { param: param, value: value }
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
      output.join(",\n") << "\n"
    end

    def full_title
      return "#{@author}/#{@name}" if @author
      @name
    end

    private

    def parse_title(title)
      if (match = title.match(/^(\w[\w-]*\w)$/))
        [nil, match[1]]
      elsif (match = title.match(%r{^(\w+)[/-](\w[\w-]*\w)$}))
        [match[1], match[2]]
      else
        raise ArgumentError, _("Module name (%{title}) must match either 'modulename' or 'owner/modulename'") % { title: title }
      end
    end

    def calculate_indent
      @indent = @params.keys.max_by(&:length).length + 1
    end
  end
end
