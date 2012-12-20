module Printers
  class Base
    class MissedPath < StandardError; end
    class MissedArgument < StandardError; end

    SEPARATOR = "."

    private

      def locate(path)
        result = nil
        contents.each do |_, contents|
          result = parts(path).inject(contents) do |r, part|
            r && r.has_key?(part) ? r[part] : nil
          end
          break if result
        end
        raise MissedPath, "Can't find part path '#{path}'" unless result
        result
      end

      def translate(string, args = {})
        string.gsub(/{([^}]*)}/) do
          key = $1.to_s.to_sym
          raise MissedArgument, "Missed argument #{$1} for '#{string}'" unless args.has_key?(key)
          args[key]
        end
      end

      def parts(path)
        path.split(SEPARATOR)
      end

      def contents
        @contents ||= contents_files.inject({}) do |hash, filename|
          hash[filename] = YAML.load_file(File.expand_path(File.join("..", "texts", "#{filename}.yml"), __FILE__)) || {}
          hash
        end
      end

      def array_of_args(collection, &block)
        collection.each.with_index.inject([]) do |array, (item, index)|
          args = block.call(item, index)
          array << args if args
          array
        end
      end

      def contents_files
        ["base"]
      end
  end
end
