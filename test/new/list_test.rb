require_relative 'test_helper'

describe "List Command" do
  include TestDsl

  before do
    @old_listsize = Debugger::Command.settings[:listsize]
    Debugger::Command.settings[:listsize] = 3
    LineCache.clear_file_cache
  end
  after do
    Debugger::Command.settings[:listsize] = @old_listsize
    LineCache.clear_file_cache
  end

  describe "without arguments" do
    it "must show surrounding lines with the first call" do
      enter 'break 5', 'cont', 'list'
      debug_file 'list'
      check_output_includes "[4, 6] in #{fullpath('list')}", "4  4", "=> 5  5", "6  6"
    end

    it "must list forward after second call" do
      enter 'break 5', 'cont', 'list', 'list'
      debug_file 'list'
      check_output_includes "[7, 9] in #{fullpath('list')}", "7  7", "8  8", "9  9"
    end
  end

  describe "list backward" do
    it "must show surrounding lines with the first call" do
      enter 'break 5', 'cont', 'list -'
      debug_file 'list'
      check_output_includes "[4, 6] in #{fullpath('list')}", "4  4", "=> 5  5", "6  6"
    end

    it "must list backward after second call" do
      enter 'break 5', 'cont', 'list -', 'list -'
      debug_file 'list'
      check_output_includes "[1, 3] in #{fullpath('list')}", "1  debugger", "2  2", "3  3"
    end
  end

  it "must show the surrounding lines with =" do
    enter 'break 5', 'cont', 'list ='
    debug_file 'list'
    check_output_includes "[4, 6] in #{fullpath('list')}", "4  4", "=> 5  5", "6  6"
  end

  describe "specified lines" do
    it "must show with mm-nn" do
      enter 'list 4-6'
      debug_file 'list'
      check_output_includes "[4, 6] in #{fullpath('list')}", "4  4", "5  5", "6  6"
    end

    it "must show with mm,nn" do
      enter 'list 4,6'
      debug_file 'list'
      check_output_includes "[4, 6] in #{fullpath('list')}", "4  4", "5  5", "6  6"
    end

    it "must show surroundings with mm-" do
      enter 'list 4-'
      debug_file 'list'
      check_output_includes "[3, 5] in #{fullpath('list')}", "3  3", "4  4", "5  5"
    end

    it "must show surroundings with mm," do
      enter 'list 4,'
      debug_file 'list'
      check_output_includes "[3, 5] in #{fullpath('list')}", "3  3", "4  4", "5  5"
    end

    it "must show nothing if there is no such lines" do
      enter 'list 44,44'
      debug_file 'list'
      check_output_includes "[44, 44] in #{fullpath('list')}"
      check_output_doesnt_include /^44  \S/
    end

    it "must show nothing if range is incorrect" do
      enter 'list 5,4'
      debug_file 'list'
      check_output_includes "[5, 4] in #{fullpath('list')}"
      check_output_doesnt_include "5  5"
      check_output_doesnt_include "4  4"
    end
  end

  describe "reload source" do
    def change_line_in_file(file, line, new_line_content)
      old_content = File.read(file)
      new_content = old_content.split("\n").tap { |c| c[line - 1] = new_line_content }.join("\n")
      File.open(file, 'w') { |f| f.write(new_content) }
    end

    it "must not reload if setting is false" do
      temporary_change_hash_value(Debugger::Command.settings, :reload_source_on_change, false) do
        begin
          enter -> do
            change_line_in_file(fullpath('list'), 4, '100')
            'list 4-4'
          end
          debug_file 'list'
          check_output_includes "4  4"
        ensure
          change_line_in_file(fullpath('list'), 4, '4')
        end
      end
    end

    it "must reload if setting is true" do
      temporary_change_hash_value(Debugger::Command.settings, :reload_source_on_change, true) do
        begin
          enter -> do
            change_line_in_file(fullpath('list'), 4, '100')
            'list 4-4'
          end
          debug_file 'list'
          check_output_includes "4  100"
        ensure
          change_line_in_file(fullpath('list'), 4, '4')
        end
      end
    end
  end

  it "must show an error when there is no such file" do
    enter ->{state.file = "blabla"; 'list 4-4'}
    debug_file 'list'
    check_output_includes "No sourcefile available for blabla", interface.error_queue
  end
end
