require_relative 'test_helper'

describe "Reload Command" do
  include TestDsl
  temporary_change_hash_value(Debugger::Command.settings, :reload_source_on_change, false)

  it "must notify that automatic reloading is off" do
    enter 'reload'
    debug_file 'reload'
    check_output_includes "Source code is reloaded. Automatic reloading is off."
  end

  it "must notify that automatic reloading is on" do
    enter 'set autoreload', 'reload'
    debug_file 'reload'
    check_output_includes "Source code is reloaded. Automatic reloading is on."
  end

  describe "reloading" do
    after { change_line_in_file(fullpath('reload'), 4, '4') }
    it "must reload the code" do
      enter 'break 3', 'cont', 'l 4-4', -> do
        change_line_in_file(fullpath('reload'), 4, '100')
        'reload'
      end, 'l 4-4'
      debug_file 'reload'
      check_output_includes "4  100"
    end
  end

end
