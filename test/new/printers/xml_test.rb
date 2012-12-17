require_relative '../test_helper'

describe "Printers::Plain" do
  include PrinterHelpers

  let(:klass) { Printers::Xml }
  let(:printer) { klass.new }
  let(:yaml_xml) do
    {
      "foo" => {
        "errors" => {
          "bad" => "bad behavior"
        },
        "confirmations" => {
          "okay" => "Okay?"
        },
        "bar" => {
          "tag" => "xmltag",
          "attributes" => {
            "boo" => "{zee} > {uga}",
            "agu" => "bew"
          }
        }
      }
    }
  end

  before do
    YAML.stubs(:load_file).with(yaml_file_path('xml')).returns(yaml_xml)
    YAML.stubs(:load_file).with(yaml_file_path('base')).returns({})
  end

  describe "#print" do
    it "must return correctly translated string" do
      xml = ::Builder::XmlMarkup.new.xmltag(boo: "zuu > aga", agu: "bew")
      printer.print("foo.bar", zee: "zuu", uga: "aga").must_equal xml
    end

    it "must return error string" do
      printer.print("foo.errors.bad").must_equal "<error>bad behavior</error>"
    end

    it "must return confirmation string" do
      printer.print("foo.confirmations.okay").must_equal "<confirmation>Okay?</confirmation>"
    end
  end
end

