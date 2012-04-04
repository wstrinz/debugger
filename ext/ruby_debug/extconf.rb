bindir = RbConfig::CONFIG['bindir']
# autodetect ruby headers
if bindir =~ %r{(^.*/\.rbenv/versions)/([^/]+)/bin$}
  ruby_include = "#{$1}/#{$2}/include/ruby-1.9.1/ruby-#{$2}"
  ARGV << "--with-ruby-include=#{ruby_include}"
elsif bindir =~ %r{(^.*/\.rvm/rubies)/([^/]+)/bin$}
  ruby_include = "#{$1}/#{$2}/include/ruby-1.9.1/#{$2}"
  ARGV << "--with-ruby-include=#{ruby_include}"
end

require "mkmf"
require "ruby_core_source"

if RUBY_VERSION < "1.9"
  STDERR.print("Ruby version is too old\n")
  exit(1)
end

hdrs = lambda {
  iseqs = %w[vm_core.h iseq.h]
  begin
    have_struct_member("rb_method_entry_t", "called_id", "method.h") or
    have_struct_member("rb_control_frame_t", "method_id", "method.h")
  end and
  have_header("vm_core.h") and have_header("iseq.h") and have_header("insns.inc") and
  have_header("insns_info.inc") and have_header("eval_intern.h") or return(false)
  have_type("struct iseq_line_info_entry", iseqs) or
  have_type("struct iseq_insn_info_entry", iseqs) or
  return(false)
  if checking_for(checking_message("if rb_iseq_compile_with_option was added an argument filepath")) do
      try_compile(<<SRC)
#include <ruby.h>
#include "vm_core.h"
extern VALUE rb_iseq_new_main(NODE *node, VALUE filename, VALUE filepath);
SRC
    end
    $defs << '-DRB_ISEQ_COMPILE_5ARGS'
  end
}

dir_config("ruby")
if !Ruby_core_source::create_makefile_with_core(hdrs, "ruby_debug")
  STDERR.print("Makefile creation failed\n")
  STDERR.print("*************************************************************\n\n")
  STDERR.print("  NOTE: If your headers were not found, try passing\n")
  STDERR.print("        --with-ruby-include=PATH_TO_HEADERS      \n\n")
  STDERR.print("*************************************************************\n\n")
  exit(1)
end
