require_relative '../test_helper'

describe "Printers::Plain" do
  include PrinterHelpers

  let(:klass) { Printers::Plain }
  let(:printer) { klass.new }
  let(:yaml_plain) do
    {
      "foo" => {
        "bar" => "plain {zee}, {uga} gaa",
        "confirmations" => {
          "okay" => "Okay?"
        }
      }
    }
  end

  let(:yaml_base) do
    {
      "foo" => {
        "bar" => "base {zee}, {uga} gaa",
        "boo" => "{zee}, gau"
      }
    }
  end

  before do
    YAML.stubs(:load_file).with(yaml_file_path('plain')).returns(yaml_plain)
    YAML.stubs(:load_file).with(yaml_file_path('base')).returns(yaml_base)
  end

  describe "#print" do
    it "must return correctly translated string" do
      printer.print("foo.bar", zee: 'zuu', uga: 'aga').must_equal "plain zuu, aga gaa\n"
    end

    it "must add (y/n) to the confirmation strings" do
      printer.print("foo.confirmations.okay").must_equal "Okay? (y/n) \n"
    end

    it "must use strings, inherited from base" do
      printer.print("foo.boo", zee: 'zuu').must_equal "zuu, gau\n"
    end
  end

  describe "errors" do
    it "must show an error if there is no specified path" do
      ->{ printer.print("foo.bla") }.must_raise klass::MissedPath
    end

    it "must show an error if there is no specified argument" do
      ->{ printer.print("foo.bar", zee: 'zuu') }.must_raise klass::MissedArgument
    end
  end

end
