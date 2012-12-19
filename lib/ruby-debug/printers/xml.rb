require_relative 'base'
require 'builder'

module Printers
  class Xml < Base

    def print(path, args = {})
      case parts(path)[1]
      when "errors"
        print_error(path, args)
      when "confirmations"
        print_confirmation(path, args)
      when "debug"
        print_debug(path, args)
      else
        print_message(path, args)
      end
    end

    private

      def print_message(path, args)
        settings = locate(path)
        xml = ::Builder::XmlMarkup.new
        tag = translate(settings["tag"], args)
        attributes = translated_attributes(settings["attributes"], args)
        xml.tag!(tag, attributes)
      end

      def print_debug(path, args)
        translate(locate(path), args)
      end

      def print_error(path, args)
        xml = ::Builder::XmlMarkup.new
        xml.error { xml.text!(translate(locate(path), args)) }
      end

      def print_confirmation(path, args)
        xml = ::Builder::XmlMarkup.new
        xml.confirmation { xml.text!(translate(locate(path), args)) }
      end

      def translated_attributes(attributes, args)
        attributes.inject({}) do |hash, (key, value)|
          hash[key] = translate(value, args)
          hash
        end
      end

      def contents_files
        ["xml"] + super
      end

  end
end
