require_relative 'test_helper'

describe "Eval Command" do
  include TestDsl

  it "must evaluate an expression" do
    enter 'eval 3 + 2'
    debug_file 'eval'
    check_output_includes "5"
  end

  it "must work with shortcut" do
    enter 'e 3 + 2'
    debug_file 'eval'
    check_output_includes "5"
  end

  it "must work with another syntax" do
    enter 'p 3 + 2'
    debug_file 'eval'
    check_output_includes "5"
  end

  it "must work with autoeval"

  it "must pretty print the expression result" do
    enter 'pp {a: "3" * 40, b: "4" * 30}'
    debug_file 'eval'
    check_output_includes "{:a=>\"#{"3" * 40}\",\n :b=>\"#{"4" * 30}\"}"
  end

  it "must print expression and columnize the result" do
    temporary_change_hash_value(Debugger::PutLCommand.settings, :width, 20) do
      enter 'putl [1, 2, 3, 4, 5, 9, 8, 7, 6]'
      debug_file 'eval'
      check_output_includes "1  3  5  8  6\n2  4  9  7"
    end
  end

  it "must print expression and sort and columnize the result" do
    temporary_change_hash_value(Debugger::PSCommand.settings, :width, 20) do
      enter 'ps [1, 2, 3, 4, 5, 9, 8, 7, 6]'
      debug_file 'eval'
      check_output_includes "1  3  5  7  9\n2  4  6  8"
    end
  end

end
