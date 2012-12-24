require_relative 'test_helper'

describe "Method Command" do
  include TestDsl

  # TODO: Need to write tests for 'method signature' command, but I can't install the 'ruby-internal' gem
  # on my machine, it fails to build gem native extension.

  describe "show instance method of a class" do
    describe "show using full command name" do
      it "must show in plain text" do
        enter 'break 15', 'cont', 'm MethodEx'
        debug_file 'method'
        check_output_includes /bla/
        check_output_doesnt_include /foo/
      end

      it "must show in xml" do
        temporary_change_method_value(Debugger, :printer, Printers::Xml.new) do
          enter 'break 15', 'cont', 'm MethodEx'
          debug_file 'method'
          check_output_includes '<methods><method name="bla"/></methods>'
        end
      end
    end

    it "must show using shortcut" do
      enter 'break 15', 'cont', 'method MethodEx'
      debug_file 'method'
      check_output_includes /bla/
    end

    it "must show an error if specified object is not a class or module" do
      enter 'break 15', 'cont', 'm a'
      debug_file 'method'
      check_output_includes "Should be Class/Module: a", interface.error_queue
    end
  end


  describe "show methods of an object" do
    describe "show using full command name" do
      it "must show in plain text" do
        enter 'break 15', 'cont', 'method instance a'
        debug_file 'method'
        check_output_includes /bla/
        check_output_doesnt_include /foo/
      end

      it "must show in plain text" do
        temporary_change_method_value(Debugger, :printer, Printers::Xml.new) do
          enter 'break 15', 'cont', 'method instance a'
          debug_file 'method'
          check_output_includes /<methods>.*<method name="bla"\/>.*<\/methods>/
        end
      end
    end

    it "must show using shortcut" do
      enter 'break 15', 'cont', 'm i a'
      debug_file 'method'
      check_output_includes /bla/
    end
  end


  describe "show instance variables of an object" do
    describe "show using full name command" do
      it "must show in plain text" do
        enter 'break 15', 'cont', 'method iv a'
        debug_file 'method'
        check_output_includes %{@a = "b"\n@c = "d"}
      end

      it "must show in xml" do
        temporary_change_method_value(Debugger, :printer, Printers::Xml.new) do
          enter 'break 15', 'cont', 'method iv a'
          debug_file 'method'
          check_output_includes(Regexp.new(
            %{<variables>} +
              %{<variable name="@a" kind="instance" value="b" type="String" hasChildren="false" objectId=".*?"/>} +
              %{<variable name="@c" kind="instance" value="d" type="String" hasChildren="false" objectId=".*?"/>} +
            %{</variables>}
          ))
        end
      end
    end

    it "must show using shortcut" do
      enter 'break 15', 'cont', 'm iv a'
      debug_file 'method'
      check_output_includes %{@a = "b"\n@c = "d"}
    end
  end


  describe "Post Mortem" do
    it "must work in post-mortem mode" do
      enter 'cont', 'm i self'
      debug_file 'post_mortem'
      check_output_includes /to_s/
    end
  end

end
