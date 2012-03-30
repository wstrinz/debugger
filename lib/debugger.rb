module Debugger
end
# TODO: merge cli/ into lib/
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../cli')

require 'ruby-debug'
require 'debugger/version'
