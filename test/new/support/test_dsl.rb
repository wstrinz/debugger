module TestDsl
  def self.included(base)
    base.class_eval do
      before do
        Debugger.interface = TestInterface.new
        Debugger.handler.display.clear
      end
      after do
        Debugger.handler.display.clear
      end
    end
  end

  # Adds commands to the input queue, so they will be retrieved by Processor later.
  # I.e. it emulates user's input.
  #
  # If a command is a Proc object, it will be executed before retrieving by Processor.
  # May be handy when you need build a command depending on the current context/state.
  #
  # Usage:
  #
  #   enter 'b 12'
  #   enter 'b 12', 'cont'
  #   enter ['b 12', 'cont']
  #   enter 'b 12', ->{"disable #{breakpoint.id}"}, 'cont'
  #
  def enter(*messages)
    messages = messages.first.is_a?(Array) ? messages.first : messages
    interface.input_queue.concat(messages)
  end

  # Runs a debugger with the provided basename for a file. The file should be placed
  # to the test/new/examples dir.
  #
  # You also can specify block, which will be executed when Processor extracts all the
  # commands from the input queue. You can use it e.g. for making asserts for the current
  # test. If you specified the block, and it never was executed, the test will fail.
  #
  # Usage:
  #
  #   debug "ex1" # ex1 should be placed in test/new/examples/ex1.rb
  #
  #   enter 'b 4', 'cont'
  #   debug("ex1") { state.line.must_equal 4 } # It will be executed after running 'cont' and stopping at the breakpoint
  #
  def debug_file(filename, &block)
    is_test_block_called = false
    debug_completed = false
    exception = nil
    if block
      interface.test_block = lambda do
        is_test_block_called = true
        # We need to store exception and reraise it after completing debugging, because
        # Debugger will swallow any exceptions, so e.g. our failed assertions will be ignored
        begin
          block.call
        rescue Exception => e
          exception = e
          raise e
        end
      end
    end
    Debugger.start do
      load fullpath(filename)
      debug_completed = true
    end
    flunk "Debug block was not completed" unless debug_completed
    flunk "test block is provided, but not called" if block && !is_test_block_called
    raise exception if exception
  end

  # Checks the output of the debugger. By default it checks output queue of the current interface,
  # but you can check again any queue by providing it as a second argument.
  #
  # Usage:
  #
  #   enter 'break 4', 'cont'
  #   debug("ex1")
  #   check_output "Breakpoint 1 at #{fullpath('ex1')}:4"
  #
  def check_output(check_method, *args)
    queue = args.last.is_a?(String) ? interface.output_queue : args.pop
    Array(args).each do |message|
      queue.map(&:strip).send(check_method, message.strip)
    end
  end

  def check_output_includes(*args)
    check_output :must_include, *args
  end

  def check_output_doesnt_include(*args)
    check_output :wont_include, *args
  end

  def fullpath(filename)
    (Pathname.new(__FILE__) + "../../examples/#{filename}.rb").cleanpath.to_s
  end

  def interface
    Debugger.handler.interface
  end

  def state
    $rdebug_state
  end

  def context
    state.context
  end

  def breakpoint
    Debugger.breakpoints.first
  end

  def force_set_const(klass, const, value)
    klass.send(:remove_const, const) if klass.const_defined?(const)
    klass.const_set(const, value)
  end

  def temporary_change_method_value(item, method, value)
    old = item.send(method)
    item.send("#{method}=", value)
    yield
  ensure
    item.send("#{method}=", old)
  end

  def temporary_change_hash_value(item, key, value)
    old_value = item[key]
    begin
      item[key] = value
      yield
    ensure
      item[key] = old_value
    end
  end

end
