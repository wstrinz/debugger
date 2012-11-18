require_relative 'test_helper'

describe "Settings" do
  include TestDsl
  before { Debugger.interface = TestInterface.new }

  describe "setting debuggertesting" do
    before do
      Debugger::Command.settings[:debuggertesting] = nil
      enter 'set debuggertesting on'
      debug_file("ex1")
    end

    it "must be set" do
      Debugger::Command.settings[:debuggertesting].must_equal true
    end

    it "must return right response" do
      check_output 'Currently testing the debugger is on.'
    end
  end


  describe "setting callstyle" do
    before do
      Debugger::Command.settings[:callstyle] = nil
      enter 'set callstyle last'
      debug_file("ex1")
    end

    it "must be set" do
      Debugger::Command.settings[:callstyle].must_equal :last
    end

    it "must return right response" do
      check_output 'Frame call-display style is last.'
    end
  end


  describe "setting autoeval" do
    before do
      Debugger::Command.settings[:autoeval] = nil
      enter 'set autoeval off'
      debug_file("ex1")
    end

    it "must be set" do
      Debugger::Command.settings[:autoeval].must_equal false
    end

    it "must return right response" do
      check_output 'autoeval is off.'
    end
  end
end
