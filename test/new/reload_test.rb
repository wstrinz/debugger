require_relative 'test_helper'

describe "Reload Command" do
  include TestDsl

  it "must notify that automatic reloading is off" do
    temporary_change_method_value(Debugger, :reload_source_on_change, false) do
      enter 'reload'
      debug_file 'reload'
      check_output_includes "Source code is reloaded. Automatic reloading is off."
    end
  end

  it "must notify that automatic reloading is on" do
    temporary_change_method_value(Debugger, :reload_source_on_change, false) do
      enter 'set autoreload', 'reload'
      debug_file 'reload'
      check_output_includes "Source code is reloaded. Automatic reloading is on."
    end
  end

  it "must reload the code" do
    temporary_change_method_value(Debugger, :reload_source_on_change, false) do
      begin
        enter 'break 3', 'cont', 'l 4-4', -> do
          change_line_in_file(fullpath('reload'), 4, '100')
          'reload'
        end, 'l 4-4'
        debug_file 'reload'
        check_output_includes "4  100"
      ensure
        change_line_in_file(fullpath('reload'), 4, '4')
      end
    end
  end

end
