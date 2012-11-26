require_relative 'test_helper'

describe "Help Command" do
  include TestDsl
  include Columnize

  let(:available_commands) do
    Debugger::Command.commands.select(&:event).map(&:help_command).flatten.uniq.sort
  end

  it "must show help how to use 'help'" do
    temporary_change_hash_value(Debugger::HelpCommand.settings, :width, 50) do
      enter 'help'
      debug_file('help')
      check_output_includes(
        "Type 'help <command-name>' for help on a specific command",
        "Available commands:",
        columnize(available_commands, 50)
      )
    end
  end

  it "must show help when use shortcut" do
    enter 'h'
    debug_file('help')
    check_output_includes "Type 'help <command-name>' for help on a specific command"
  end

  it "must show an error if undefined command is specified" do
    enter 'help foobar'
    debug_file('help')
    check_output_includes 'Undefined command: "foobar".  Try "help".', interface.error_queue
  end

  it "must show a command's help" do
    enter 'help break'
    debug_file('help')
    check_output_includes Debugger::AddBreakpoint.help(nil).split("\n").map { |l| l.gsub(/^ +/, '') }.join("\n")
  end
end
