$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'validated_stack'
require 'main_stack_validator'

class MainStackValidatorTest < Test::Unit::TestCase

  def setup
    @v = MainStackValidator.new
  end

  def test_valid_stack_can_be_constructed
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    ValidatedStack.new [c1, c2], @v
  end

  def test_invalid_stack_cannot_be_constructed
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :hearts)
    assert_raise(RuntimeError) {
      ValidatedStack.new [c1, c2], @v
    }
  end

  def test_can_append_when_valid
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    c3 = Card.new(8, :diamonds)
    c4 = Card.new(7, :clubs)

    s1 = ValidatedStack.new [c1, c2], @v
    s2 = StackOfCards.new [c3, c4]

    s3 = s1.append_stack s2

    assert_equal 4, s3.size
    assert_equal c1, s3[0]
    assert_equal c2, s3[1]
    assert_equal c3, s3[2]
    assert_equal c4, s3[3]
  end

  def test_cannot_append_when_stacks_are_valid_but_not_sequential
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    c3 = Card.new(7, :diamonds)
    c4 = Card.new(6, :clubs)

    s1 = ValidatedStack.new [c1, c2], @v
    s2 = StackOfCards.new [c3, c4]

    assert_raise(RuntimeError) {
      s1.append_stack s2
    }
  end

  def test_cannot_append_when_second_stack_is_invalid
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    c3 = Card.new(8, :diamonds)
    c4 = Card.new(8, :clubs)

    s1 = ValidatedStack.new [c1, c2], @v
    s2 = StackOfCards.new [c3, c4]

    assert_raise(RuntimeError) {
      s1.append_stack s2
    }
  end

  def test_can_append_returns_new_stack
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    c3 = Card.new(8, :diamonds)
    c4 = Card.new(7, :clubs)

    s1 = ValidatedStack.new [c1, c2], @v
    s2 = StackOfCards.new [c3, c4]

    s3 = s1.append_stack s2

    assert_equal 2, s1.size
    assert_equal 2, s2.size
    assert s3 != s1
    assert s3 != s2
  end

  def test_append_card_when_valid
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    c3 = Card.new(8, :diamonds)
    s1 = ValidatedStack.new [c1, c2], @v

    s2 = s1.append_card(c3)

    assert_equal 3, s2.size
    assert_equal c1, s2[0]
    assert_equal c2, s2[1]
    assert_equal c3, s2[2]
  end

  def test_cannot_append_card_when_invalid
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    c3 = Card.new(10, :diamonds)
    s1 = ValidatedStack.new [c1, c2], @v

    assert_raise(RuntimeError) {
      s1.append_card(c3)
    }
  end

  def test_append_card_returns_new_stack
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    c3 = Card.new(8, :diamonds)
    s1 = ValidatedStack.new [c1, c2], @v

    s2 = s1.append_card(c3)

    assert s1 != s2
    assert_equal 2, s1.size
  end

  def test_remove_stack
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    c3 = Card.new(8, :diamonds)
    c4 = Card.new(7, :clubs)

    s1 = ValidatedStack.new [c1, c2, c3, c4], @v
    new_stack, removed_stack = s1.remove_stack(2)

    assert_equal 2, new_stack.size
    assert_equal c1, new_stack[0]
    assert_equal c2, new_stack[1]

    assert_equal 2, removed_stack.size
    assert_equal c3, removed_stack[0]
    assert_equal c4, removed_stack[1]
  end

  def test_remove_stack_doesnt_change_original
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    c3 = Card.new(8, :diamonds)
    c4 = Card.new(7, :clubs)

    s1 = ValidatedStack.new [c1, c2, c3, c4], @v
    s1d = s1.dup
    s1.remove_stack(2)

    assert_equal s1d, s1
  end

  def test_remove_card
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    c3 = Card.new(8, :diamonds)
    c4 = Card.new(7, :clubs)

    s1 = ValidatedStack.new [c1, c2, c3, c4], @v
    new_stack, removed_card = s1.remove_card

    assert_equal 3, new_stack.size
    assert_equal c1, new_stack[0]
    assert_equal c2, new_stack[1]
    assert_equal c3, new_stack[2]
    assert_equal c4, removed_card
  end

  def test_remove_card_doesnt_change_original
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    c3 = Card.new(8, :diamonds)
    c4 = Card.new(7, :clubs)

    s1 = ValidatedStack.new [c1, c2, c3, c4], @v
    s1d = s1.dup
    s1.remove_card

    assert_equal s1d, s1
  end

  def test_eql
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    s1 = ValidatedStack.new [c1, c2], @v
    s2 = ValidatedStack.new [c1, c2], @v

    assert_equal s1, s2
  end

  def test_eql_fails_on_different_contents
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    c3 = Card.new(8, :diamonds)
    s1 = ValidatedStack.new [c1, c2], @v
    s2 = ValidatedStack.new [c1, c2, c3], MainStackValidator.new

    assert_not_equal s1, s2
  end

  def test_eql_fails_on_different_validator
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    s1 = ValidatedStack.new [c1, c2], @v
    s2 = ValidatedStack.new [c1, c2], MainStackValidator.new

    assert_not_equal s1, s2
  end
end
