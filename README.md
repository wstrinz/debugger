## Description
A fork of ruby-debug19 that works on 1.9.3 and installs easily for rvm/rbenv rubies.

## Install

    $ gem install debugger -v 1.0.0.rc1
    # Will bump to 1.0.0 when I've gotten feedback

## Usage

```ruby
require 'debugger'; debugger
```

## Reason for Fork

* ruby-debug19 maintainer isn't maintaining:
  * no rubygems release in 2+ years! - 9/1/09
  * sitting on patches from ruby-core
  * Doesn't have github issues open - rubyforge, really?
* [Current Install](http://blog.wyeworks.com/2011/11/1/ruby-1-9-3-and-ruby-debug)
  [Workarounds Required](https://gist.github.com/1331533)
* We need a decent ruby debugger for future rubies!

## Credits

Started on awesome @relevance fridays!

## Contributing
[See here](http://tagaholic.me/contributing.html) for normal contribution policies. I'm willing
to lower the bar for now since tests aren't up and I need all the C help I can get. Let's keep
this working for the ruby community!

## TODO

* Fix tests and put them up on CI
* Get working on 1.9.2
* Get working on jruby + rubinius
* Try to remove ruby_source as a dependency
* Clean up (merge) lib + cli as separate runtime paths for ruby-debug-base19 and ruby-debug19
