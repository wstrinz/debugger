require_relative 'test_helper'

describe "Breakpoints" do
  include TestDsl

  describe "setting breakpoint in the current file" do
    before { enter 'break 10' }
    subject { Debugger.breakpoints.first }

    def check_subject(field, value)
      debug_file("breakpoint1") { subject.send(field).must_equal value }
    end

    it("must have correct pos") { check_subject(:pos, 10) }
    it("must have correct source") { check_subject(:source, fullpath("breakpoint1")) }
    it("must have correct expression") { check_subject(:expr, nil) }
    it("must have correct hit count") { check_subject(:hit_count, 0) }
    it("must have correct hit value") { check_subject(:hit_value, 0) }
    it("must be enabled") { check_subject(:enabled?, true) }
    it("must return right response") do
      id = nil
      debug_file('breakpoint1') { id = subject.id }
      check_output "Breakpoint #{id} file #{fullpath('breakpoint1')}, line 10"
    end
  end


  describe "using shortcut for the command" do
    before { enter 'b 10' }
    it "must set a breakpoint" do
      debug_file("breakpoint1") { Debugger.breakpoints.size.must_equal 1 }
    end
  end


  describe "setting breakpoint to unexisted line" do
    before { enter 'break 100' }

    it "must not create a breakpoint" do
      debug_file("breakpoint1") { Debugger.breakpoints.must_be_empty }
    end

    it "must show an error" do
      debug_file("breakpoint1")
      check_output "There are only #{LineCache.size(fullpath('breakpoint1'))} lines in file \"breakpoint1.rb\".", interface.error_queue
    end
  end


  describe "setting breakpoint to incorrect line" do
    before { enter 'break 8' }

    it "must not create a breakpoint" do
      debug_file("breakpoint1") { Debugger.breakpoints.must_be_empty }
    end

    it "must show an error" do
      debug_file("breakpoint1")
      check_output 'Line 8 is not a stopping point in file "breakpoint1.rb".', interface.error_queue
    end
  end


  describe "stopping at breakpoint" do
    before do
      enter 'break 14', 'cont'
    end

    it "must stop at the correct line" do
      debug_file("breakpoint1") { state.line.must_equal 14 }
    end

    it "must stop at the correct file" do
      debug_file("breakpoint1") { state.file.must_equal fullpath("breakpoint1") }
    end

    it "must show a message" do
      debug_file("breakpoint1")
      check_output "Breakpoint 1 at #{fullpath('breakpoint1')}:14"
    end
  end


  describe "set breakpoint in a file" do
    describe "successfully" do
      before do
        enter "break #{fullpath('breakpoint2')}:3", 'cont'
      end

      it "must stop at the correct line" do
        debug_file("breakpoint1") { state.line.must_equal 3 }
      end

      it "must stop at the correct file" do
        debug_file("breakpoint1") { state.file.must_equal fullpath("breakpoint2") }
      end
    end

    describe "when setting breakpoint to unexisted file" do
      before do
        enter "break asf:324"
        debug_file("breakpoint1")
      end
      it "must show an error" do
        check_output "No source file named asf", interface.error_queue
      end

      it "must ask about setting breakpoint anyway" do
        check_output "Set breakpoint anyway? (y/n)", interface.confirm_queue
      end
    end
  end


  describe "set breakpoint to a method" do
    describe "set breakpoint to an instance method" do
      before do
        enter 'break A#b', 'cont'
      end

      it "must stop at the correct line" do
        debug_file("breakpoint1") { state.line.must_equal 5 }
      end

      it "must stop at the correct file" do
        debug_file("breakpoint1") { state.file.must_equal fullpath("breakpoint1") }
      end
    end

    describe "set breakpoint to a class method" do
      before do
        enter 'break A.a', 'cont'
      end

      it "must stop at the correct line" do
        debug_file("breakpoint1") { state.line.must_equal 2 }
      end

      it "must stop at the correct file" do
        debug_file("breakpoint1") { state.file.must_equal fullpath("breakpoint1") }
      end
    end

    describe "set breakpoint to unexisted class" do
      it "must show an error" do
        enter "break B.a"
        debug_file("breakpoint1")
        check_output "Unknown class B.", interface.error_queue
      end
    end
  end


  describe "set breakpoint to an invalid location" do
    before { enter "break foo" }

    it "must not create a breakpoint" do
      debug_file("breakpoint1") { Debugger.breakpoints.must_be_empty }
    end

    it "must show an error" do
      debug_file("breakpoint1")
      check_output 'Invalid breakpoint location: foo.', interface.error_queue
    end
  end


  describe "disabling a breakpoint" do
    before { enter "break 14", ->{"disable #{Debugger.breakpoints.first.id}"}, "break 15" }

    it "must have a breakpoint with #enabled? returning false" do
      debug_file("breakpoint1") { Debugger.breakpoints.first.enabled?.must_equal false }
    end

    it "must not stop on the disabled breakpoint" do
      enter "cont"
      debug_file("breakpoint1") { state.line.must_equal 15 }
    end
  end


  describe "deleting a breakpoint" do
    before { enter "break 14", ->{"delete #{Debugger.breakpoints.first.id}"}, "break 15" }

    it "must have only one breakpoint" do
      debug_file("breakpoint1") { Debugger.breakpoints.size.must_equal 1 }
    end

    it "must not stop on the disabled breakpoint" do
      enter "cont"
      debug_file("breakpoint1") { state.line.must_equal 15 }
    end
  end


  describe "Conditional breakpoints" do
    it "must stop if the condition is correct" do
      enter "break 14 if b == 5", "break 15", "cont"
      debug_file("breakpoint1") { state.line.must_equal 14 }
    end

    it "must skip if the condition is incorrect" do
      enter "break 14 if b == 3", "break 15", "cont"
      debug_file("breakpoint1") { state.line.must_equal 15 }
    end

    it "must show an error when conditional syntax is wrong" do
      enter "break 14 ifa b == 3", "break 15", "cont"
      debug_file("breakpoint1") { state.line.must_equal 15 }
      check_output "Expecting 'if' in breakpoint condition; got: ifa b == 3.", interface.error_queue
    end

    it "must show an error if no file or line is specified" do
      enter "break ifa b == 3", "break 15", "cont"
      debug_file("breakpoint1") { state.line.must_equal 15 }
      check_output "Invalid breakpoint location: ifa b == 3.", interface.error_queue
    end

    it "must show an error if expression syntax is invalid" do
      enter "break if b -=) 3", "break 15", "cont"
      debug_file("breakpoint1") { state.line.must_equal 15 }
      check_output 'Expression "b -=) 3" syntactically incorrect; breakpoint disabled.', interface.error_queue
    end
  end

end
