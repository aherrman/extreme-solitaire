$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'hash_helper'

class HHTestClass
  attr_reader :value1, :value2

  include HashHelper

  def initialize(val1, val2)
    @value1 = val1
    @value2 = val2
  end

  def hash
    generate_hash([:@value1, :@value2])
  end
end

class EmptyHHTest
  include HashHelper

  def hash
    generate_hash()
  end
end

class HashHelperTest < Test::Unit::TestCase
  def test_generate_hash_creates_unique_hashes
    obj1 = HHTestClass.new 10, "Hi there"
    obj2 = HHTestClass.new 11, "Hi there"

    assert_not_equal obj1.hash, obj2.hash
  end

  def test_generate_hash_creates_same_hash_for_same_values
    obj1 = HHTestClass.new 10, "Hi there"
    obj2 = HHTestClass.new 10, "Hi there"

    assert_equal obj1.hash, obj2.hash
  end

  def test_empty_hash_is_zero
    obj1 = EmptyHHTest.new

    assert_equal 0, obj1.hash
  end
end
