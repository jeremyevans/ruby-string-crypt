ENV['MT_NO_PLUGINS'] = '1' # Work around stupid autoloading of plugins
gem 'minitest'
require 'minitest/autorun'
require_relative '../lib/string/crypt'

class TestString < Minitest::Test
  def initialize(*args)
    super
    @cls = String
  end

  def S(arg)
    @cls.new(arg)
  end

  def test_crypt
    assert_equal(S('aaGUC/JkO9/Sc'), S("mypassword").crypt(S("aa")))
    refute_equal(S('aaGUC/JkO9/Sc'), S("mypassword").crypt(S("ab")))
    assert_raises(ArgumentError) {S("mypassword").crypt(S(""))}
    assert_raises(ArgumentError) {S("mypassword").crypt(S("\0a"))}
    assert_raises(ArgumentError) {S("mypassword").crypt(S("a\0"))}
    assert_raises(ArgumentError) {S("poison\u0000null").crypt(S("aa"))}
    [Encoding::UTF_16BE, Encoding::UTF_16LE,
     Encoding::UTF_32BE, Encoding::UTF_32LE].each do |enc|
      assert_raises(ArgumentError) {S("mypassword").crypt(S("aa".encode(enc)))}
      assert_raises(ArgumentError) {S("mypassword".encode(enc)).crypt(S("aa"))}
    end
  end
end

class TestString2 < TestString
  class S2 < String
  end

  def initialize(*args)
    super
    @cls = S2
  end
end
