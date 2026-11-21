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

  def des_crypt_supported?
    s = "aa".crypt("ab")
    s.start_with?("ab") && s.bytesize == 13
  rescue NotImplementedError, SystemCallError
    false
  end

  if "".respond_to?(:crypt)
    def test_crypt
      if des_crypt_supported?
        pass      = "aaGUC/JkO9/Sc"
        good_salt = "aa"
        bad_salt  = "ab"
      else
        pass      = "$2a$04$0WVaz0pV3jzfZ5G5tpmHWuBQGbkjzgtSc3gJbmdy0GAGMa45MFM2."
        good_salt = "$2a$04$0WVaz0pV3jzfZ5G5tpmHWu"
        bad_salt  = "$2a$04$0WVaz0pV3jzfZ5G5tpmHXu"
      end
      assert_equal(S(pass), S("mypassword").crypt(S(good_salt)))
      refute_equal(S(pass), S("mypassword").crypt(S(bad_salt)))
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
  else
    def test_crypt
      assert_raises(NotImplementedError) {S("mypassword").crypt(S("aa"))}
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
