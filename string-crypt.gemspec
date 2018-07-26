Gem::Specification.new do |s|
  s.name = 'string-crypt'
  s.version = '0.9.0'
  s.platform = Gem::Platform::RUBY
  s.summary = "Backward compatible implementation of String#crypt"
  s.author = "Ruby Contributors, Jeremy Evans"
  s.email = "code@jeremyevans.net"
  s.homepage = "http://github.com/jeremyevans/ruby-string-crypt"
  s.required_ruby_version = ">= 2.1"
  s.files = %w(BSDL CHANGELOG README.rdoc Rakefile test/test_string_crypt.rb) + Dir['ext/string/crypt/{crypt.c,extconf.rb,missing/{crypt.[ch],des_tables.c}}']
  s.license = 'BSD-2-Clause'
  s.extensions << 'ext/string/crypt/extconf.rb'
  s.description = <<END
This provides a backwards-compatible String#crypt method that will
work when String#crypt is deprecated or removed from Ruby.
END
end
