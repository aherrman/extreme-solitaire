# 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'enum_helpers'

class EnumHelpersTest < Test::Unit::TestCase
  def test_are_contents_the_same_when_same_array
    a = [1, 2, 3, 4, 5]

    assert are_contents_the_same?(a, a)
  end

  def test_are_contents_the_same_when_identical
    a = [1, 2, 3, 4, 5]
    b = [1, 2, 3, 4, 5]

    assert are_contents_the_same?(a, b)
  end

  def test_are_contents_the_same_when_same_but_different_order
    a = [1, 2, 3, 4, 5]
    b = [1, 2, 5, 4, 3]

    assert are_contents_the_same?(a, b)
  end

  def test_are_contents_the_same_with_dup_vals
    a = [1, 4, 3, 4, 5]
    b = [4, 1, 5, 4, 3]

    assert are_contents_the_same?(a, b)
  end

  def test_are_contents_the_same_with_same_vals_but_diff_counts
    a = [1, 4, 3, 3, 5]
    b = [4, 1, 5, 4, 3]

    assert !are_contents_the_same?(a, b)
  end

  def test_are_contents_the_same_with_diff_sizes
    a = [1, 4, 3, 3, 5]
    b = [4, 1, 5, 4, 3, 5]

    assert !are_contents_the_same?(a, b)
    assert !are_contents_the_same?(b, a)
  end
end
