# -*- encoding: utf-8 -*-
require 'rubygems' unless defined? Gem
require File.dirname(__FILE__) + "/lib/debugger/version"

Gem::Specification.new do |s|
  s.name = %q{debugger}
  s.version = Debugger::VERSION
  s.authors = ["Kent Sibilev", "Mark Moseley", "Gabriel Horner"]
  s.email = "gabriel.horner@gmail.com"
  s.homepage = "http://github.com/cldwalker/debugger"
  s.summary = %q{Fast Ruby debugger - core component}
  s.description = %q{debugger is a fast implementation of the standard Ruby debugger debug.rb.
It is implemented by utilizing a new Ruby C API hook. The core component
provides support that front-ends can build on. It provides breakpoint
handling, bindings for stack frames among other things.
}
  s.required_rubygems_version = ">= 1.3.6"
  s.extra_rdoc_files = [
    "README",
     "ext/ruby_debug/ruby_debug.c"
  ]
  s.files = `git ls-files`.split("\n")
  # s.files = [
  #   "AUTHORS",
  #   "CHANGES",
  #   "LICENSE",
  #   "README",
  #   "Rakefile",
  #   "ext/ruby_debug/extconf.rb",
  #   "ext/ruby_debug/breakpoint.c",
  #   "ext/ruby_debug/ruby_debug.h",
  #   "ext/ruby_debug/ruby_debug.c",
  #   "lib/ruby-debug-base.rb",
  #   "lib/debugger.rb",
  #   "lib/debugger/version.rb",
  #   "lib/ChangeLog"
  # ]
  # s.test_files = [
  #   "test/base/base.rb",
  #   "test/base/binding.rb",
  #   "test/base/catchpoint.rb"
  #   ]
  # s.files += s.test_files
  s.extensions << "ext/ruby_debug/extconf.rb"
  s.add_dependency("columnize", ">= 0.3.1")
  s.add_dependency("ruby_core_source", ">= 0.1.4")
  s.add_dependency("linecache19", ">= 0.5.11")
end
