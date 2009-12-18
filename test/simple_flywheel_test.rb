# 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'simple_flywheel'

class SFTTestClass
  attr_reader :value1, :value2

  extend SimpleFlywheel

  def initialize(val1, val2)
    @value1 = val1
    @value2 = val2
  end
end

class SimpleFlywheelTest < Test::Unit::TestCase

  def setup
    SFTTestClass.clear_flywheel_cache
  end

  def test_get_passes_args_to_initialize
    o = SFTTestClass.get 3, 4

    assert_equal 3, o.value1
    assert_equal 4, o.value2
  end

  def test_get_fails_if_new_fails
    assert_raise(ArgumentError) {
      SFTTestClass.get 3
    }
  end

  def test_get_returns_same_object_for_same_arguments
    o1 = SFTTestClass.get 3, 4
    o2 = SFTTestClass.get 3, 4

    assert o1.equal?(o2)
  end

  def test_get_returns_different_object_for_different_arguments
    o1 = SFTTestClass.get 3, 4
    o2 = SFTTestClass.get 3, 5

    assert ! o1.equal?(o2)
  end

  def test_clear_cache
    o1 = SFTTestClass.get 3, 4

    SFTTestClass.clear_flywheel_cache

    o2 = SFTTestClass.get 3, 4

    assert ! o1.equal?(o2)
  end
end
