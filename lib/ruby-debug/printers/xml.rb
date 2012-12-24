require_relative 'base'
require 'builder'
require 'syck'

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
      when "messages"
        print_message(path, args)
      else
        print_general(path, args)
      end
    end

    def print_collection(path, collection, &block)
      settings = locate(path)
      xml = ::Builder::XmlMarkup.new
      tag = translate(settings["tag"])
      xml.tag!("#{tag}s") do |xml|
        array_of_args(collection, &block).each do |args|
          xml.tag!(tag, translated_attributes(settings["attributes"], args))
        end
      end
    end

    def print_variables(path, variables, kind)
      print_collection(path, variables) do |(key, value), index|
        Variable.new(key, value, kind).to_hash
      end
    end

    private

      def print_general(path, args)
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
        xml.error { print_content(xml, path, args) }
      end

      def print_confirmation(path, args)
        xml = ::Builder::XmlMarkup.new
        xml.confirmation { print_content(xml, path, args) }
      end

      def print_message(path, args)
        xml = ::Builder::XmlMarkup.new
        xml.message { print_content(xml, path, args) }
      end

      def print_content(xml, path, args)
        xml.text!(translate(locate(path), args))
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

    class Variable
      attr_reader :name, :kind
      def initialize(name, value, kind = nil)
        @name = name.to_s
        @value = value
        @kind = kind
      end

      def has_children?
        if @value.is_a?(Array) || @value.is_a?(Hash)
          !@value.empty?
        else
          !@value.instance_variables.empty? || !@value.class.class_variables.empty?
        end
      rescue
        false
      end

      def value
        if @value.is_a?(Array) || @value.is_a?(Hash)
          if has_children?
            "#{@value.class} (#{@value.size} element(s))"
          else
            "Empty #{@value.class}"
          end
        else
          value_str = @value.nil? ? 'nil' : @value.to_s
          if !value_str.is_a?(String)
            "ERROR: #{@value.class}.to_s method returns #{value_str.class}. Should return String."
          elsif value_str.is_binary_data?
            "[Binary Data]"
          else
            value_str.gsub(/^(")(.*)(")$/, '\2')
          end
        end
      rescue => e
        "<raised exception: #{e}>"
      end

      def id
        @value.respond_to?(:object_id) ? "%#+x" % @value.object_id : nil
      rescue
        nil
      end

      def type
        @value.class
      rescue
        "Undefined"
      end

      def to_hash
        {name: @name, kind: @kind, value: value, type: type, has_children: has_children?, id: id}
      end
    end

  end
end
