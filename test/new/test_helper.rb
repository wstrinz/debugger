require 'pathname'
require 'rubygems'
require 'minitest/autorun'

lib_path = (Pathname.new(__FILE__) + "../../../lib").cleanpath
$LOAD_PATH.unshift(lib_path)

require 'debugger'
Dir.glob(File.expand_path("../support/*.rb", __FILE__)).each { |f| require f }

Debugger::Command.settings[:debuggertesting] = true
