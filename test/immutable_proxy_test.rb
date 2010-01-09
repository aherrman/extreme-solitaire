# Unit tests for ImmutableProxy

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'immutable_proxy'

class ImmutableProxyTest < Test::Unit::TestCase

  class TestMutableClass
    def initialize(value)
      @value = value
    end

    def get_value
      @value
    end

    def set_value!(value)
      @value = value
    end
  end

  def setup
    @mutable = TestMutableClass.new :initial_value
    @proxy = ImmutableProxy.new @mutable
  end

  def test_proxy_calls_normal_method
    assert_equal :initial_value, @proxy.get_value
  end

  def test_proxy_blocks_mutating_method
    assert_raise(RuntimeError) do
      @proxy.set_value!(:new_value)
    end
  end

  def test_proxy_responds_to_normal_method
    assert @proxy.respond_to?(:get_value)
  end

  def test_proxy_does_not_respond_to_mutating_method
    assert ! @proxy.respond_to?(:set_value!)
  end

  def test_proxy_throws_no_method_error_on_nonexistant_mutating_function
    assert_raise(NoMethodError) do
      @proxy.do_something!
    end
  end

  def test_equality
    p1 = ImmutableProxy.new 10
    p2 = ImmutableProxy.new 10

    assert_equal p1, p2
  end

  def test_inequality
    p1 = ImmutableProxy.new 10
    p2 = ImmutableProxy.new 11

    assert_not_equal p1, p2
  end

  def test_hash
    val = 10
    proxy = ImmutableProxy.new 10

    assert_equal val.hash, proxy.hash
  end

  def test_is_a
    proxy = ImmutableProxy.new 10
    assert proxy.is_a?(10.class)
  end

  def test_dup
    proxy = ImmutableProxy.new 10
    proxy2 = proxy.dup
    assert_equal proxy, proxy2
    assert ! proxy.equal?(proxy2)
  end

  def test_nil
    proxy = ImmutableProxy.new nil
    assert proxy.nil?
  end

  def test_masked_method
    proxy = ImmutableProxy.new 10
    assert_equal 10.class, proxy.send_to_target(:class)
  end
end
