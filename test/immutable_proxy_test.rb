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
end
