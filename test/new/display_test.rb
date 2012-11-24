require_relative 'test_helper'

describe "Display Command" do
  include TestDsl
  before { Debugger.handler.display.clear }

  it "must show expressions" do
    enter 'display d + 1', 'break 3', 'cont'
    debug_file('display')
    check_output_includes "1: ", "d + 1 = 5"
  end

  it "must not add display to always_run if Debugger.annotate is > 1"

  it "must work with shortcut" do
    enter 'disp d + 1', 'break 3', 'cont'
    debug_file('display')
    check_output_includes "1: ", "d + 1 = 5"
  end

  it "must save displayed expressions" do
    enter 'display d + 1'
    debug_file('display') { state.display.must_equal [[true, "d + 1"]] }
  end

  it "displays all expressions available" do
    enter 'break 3', 'cont', -> do
      Debugger.handler.display.concat([[true, "abc"], [true, "d"]]); 'display'
    end
    debug_file('display')
    check_output_includes "1: ", "abc = ", "2: ", "d = 4"
  end

  describe "undisplay" do
    describe "undisplay all" do
      before do
        enter 'break 3', 'cont', -> do
          Debugger.handler.display.concat([[true, "abc"], [true, "d"]])
          'undisplay'
        end, confirm_response, 'display'
      end

      describe "confirmation is successful" do
        let(:confirm_response) { 'y' }

        it "must ask about confirmation" do
          debug_file('display')
          check_output_includes "Clear all expressions? (y/n)", interface.confirm_queue
        end

        it "must set all expressions saved to 'false'" do
          debug_file('display') { state.display.must_equal [[false, "abc"], [false, "d"]] }
        end

        it "must not show any output" do
          debug_file('display')
          check_output_doesnt_include "1: ", "abc = ", "2: ", "d = 4"
        end
      end

      describe "confirmation is unsuccessful" do
        let(:confirm_response) { 'n' }

        it "must set all expressions saved to 'false'" do
          debug_file('display') { state.display.must_equal [[true, "abc"], [true, "d"]] }
        end

        it "must not show any output" do
          debug_file('display')
          check_output_includes "1: ", "abc = ", "2: ", "d = 4"
        end
      end
    end

    describe "undisplay specific position" do
      before do
        enter 'break 3', 'cont', -> do
          Debugger.handler.display.concat([[true, "abc"], [true, "d"]])
          'undisplay 1'
        end, 'display'
      end

      it "must set inactive positions" do
        debug_file('display') { state.display.must_equal [[nil, "abc"], [true, "d"]] }
      end

      it "must display only the active position" do
        debug_file('display')
        check_output_includes "2: ", "d = 4"
      end

      it "must not display the disabled position" do
        debug_file('display')
        check_output_doesnt_include "1: ", "abc"
      end
    end
  end
end
