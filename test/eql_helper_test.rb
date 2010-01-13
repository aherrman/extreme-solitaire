
$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'eql_helper'

class EHTestClass
  attr_reader :value1, :value2

  include EqlHelper

  def initialize(val1, val2)
    @value1 = val1
    @value2 = val2
  end

  def eql?(other)
    check_equal(other, [:@value1, :@value2])
  end

  def ==(other)
    check_equal(other, [:@value1, :@value2])
  end
end

class EmptyEHTest
  include EqlHelper

  def eql?(other)
    check_equal(other, [])
  end

  def ==(other)
    check_equal(other, [:@value1, :@value2])
  end
end

class EqlHelperTest < Test::Unit::TestCase
  def test_eql_returns_false_when_data_is_different
    obj1 = EHTestClass.new 10, "Hi there"
    obj2 = EHTestClass.new 11, "Hi there"

    assert_not_equal obj1, obj2
  end

  def test_eql_returns_true_when_data_is_same
    obj1 = EHTestClass.new 10, "Hi there"
    obj2 = EHTestClass.new 10, "Hi there"

    assert_equal obj1, obj2
  end

  def test_empty_objects_of_same_type_are_equal
    obj1 = EmptyEHTest.new
    obj2 = EmptyEHTest.new

    assert_equal obj1, obj2
  end

  def test_empty_objects_of_different_type_are_not_equal
    obj1 = EmptyEHTest.new
    obj2 = Object.new

    assert_not_equal obj1, obj2
  end
end
