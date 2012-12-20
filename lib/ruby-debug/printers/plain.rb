module Printers
  class Plain < Base

    def print(path, args = {})
      message = translate(locate(path), args)
      message << " (y/n) " if parts(path).include?("confirmations")
      message << "\n"
    end

    def print_collection(path, collection, &block)
      array_of_args(collection, &block).map do |args|
        print(path, args)
      end.join("")
    end

    private

      def contents_files
        ["plain"] + super
      end

  end
end
