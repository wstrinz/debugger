module Printers
  class Plain < Base

    def print(path, args = {})
      message = translate(locate(path), args)
      message << " (y/n) " if parts(path).include?("confirmations")
      message << "\n"
    end

    private

      def contents_files
        ["plain"] + super
      end

  end
end
