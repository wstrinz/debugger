require_relative 'test_helper'

describe "Frame Command" do
  include TestDsl

  it "must go up" do
    enter 'break 25', 'cont', 'up'
    debug_file('frame') { state.line.must_equal 21 }
  end

  it "must go up by specific number of frames" do
    enter 'break 25', 'cont', 'up 2'
    debug_file('frame') { state.line.must_equal 17 }
  end

  it "must go down" do
    enter 'break 25', 'cont', 'up', 'down'
    debug_file('frame') { state.line.must_equal 25 }
  end

  it "must go down by specific number of frames" do
    enter 'break 25', 'cont', 'up 3', 'down 2'
    debug_file('frame') { state.line.must_equal 21 }
  end

  it "must set frame" do
    enter 'break 25', 'cont', 'frame 2'
    debug_file('frame') { state.line.must_equal 17 }
  end

  it "must set frame to the first one by default" do
    enter 'break 25', 'cont', 'up', 'frame'
    debug_file('frame') { state.line.must_equal 25 }
  end

  it "must print current stack frame when without arguments" do
    enter 'break 25', 'cont', 'up', 'frame'
    debug_file('frame')
    check_output_includes "#0 ", "A.d"
  end

  it "must set frame to the first one" do
    enter 'break 25', 'cont', 'up', 'frame 0'
    debug_file('frame') { state.line.must_equal 25 }
  end

  it "must set frame to the last one" do
    enter 'break 25', 'cont', 'frame -1'
    debug_file('frame') { state.line.must_equal 60 }
  end

  it "must not set frame if the frame number is too low" do
    enter 'break 25', 'cont', 'down'
    debug_file('frame') { state.line.must_equal 25 }
    check_output_includes "Adjusting would put us beyond the newest (innermost) frame.", interface.error_queue
  end

  it "must not set frame if the frame number is too high" do
    enter 'break 25', 'cont', 'up 100'
    debug_file('frame') { state.line.must_equal 25 }
    check_output_includes "Adjusting would put us beyond the oldest (initial) frame.", interface.error_queue
  end

  it "must display current backtrace" do
    enter 'break 25', 'cont', 'where'
    debug_file('frame')
    check_output_includes(
      "-->", "#0", "A.d", "at line #{fullpath('frame')}:25",
             "#1", "A.c", "at line #{fullpath('frame')}:21",
             "#2", "A.b", "at line #{fullpath('frame')}:17",
             "#3", "A.a", "at line #{fullpath('frame')}:14"
    )
  end

  it "must change frame in another thread"
  it "must not change frame in another thread if specified thread doesn't exist"
end
