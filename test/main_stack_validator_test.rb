$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'stack_of_cards'
require 'main_stack_validator'

class MainStackValidatorTest < Test::Unit::TestCase

  def setup
    @v = MainStackValidator.get
  end

  def test_get_returns_same_instance_every_time
    v1 = MainStackValidator.get
    v2 = MainStackValidator.get

    assert_equal v1, v2
    assert v1.equal?(v2)
  end

  def test_is_valid_stack_returns_false_if_invalid
    c1 = Card.new(10, :hearts)
    c2 = Card.new(11, :hearts)
    invalid_stack = StackOfCards.new [c1, c2]

    assert ! @v.is_valid_stack?(invalid_stack)
  end

  def test_is_valid_stack_returns_false_if_has_ace
    c1 = Card.new(1, :hearts)
    invalid_stack = StackOfCards.new [c1]

    assert ! @v.is_valid_stack?(invalid_stack)
  end

  def test_is_valid_returns_true_if_valid
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    valid_stack = StackOfCards.new [c1, c2]

    assert @v.is_valid_stack?(valid_stack)
  end

  def test_can_append_to_empty_stack
    c1 = Card.new(2, :hearts)
    s = StackOfCards.new []

    assert @v.can_append_card?(s, c1)
  end

  def test_cannot_append_ace_to_empty_stack
    c1 = Card.new(1, :hearts)
    s = StackOfCards.new []

    assert !@v.can_append_card?(s, c1)
  end

  def test_can_append_empty_to_empty
    s1 = StackOfCards.new []
    s2 = StackOfCards.new []

    assert @v.can_append?(s1, s2)
  end

  def test_can_append_card_returns_true_if_valid
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    s = StackOfCards.new [c1, c2]

    c3 = Card.new(8, :diamonds)
    assert @v.can_append_card?(s, c3)
  end

  def test_can_append_card_returns_false_if_invalid
    c1 = Card.new(10, :hearts)
    c2 = Card.new(9, :clubs)
    s = StackOfCards.new [c1, c2]

    c3 = Card.new(8, :clubs)
    assert !@v.can_append_card?(s, c3)
  end

  def test_can_append_if_stack_is_valid
    ten_of_hearts = Card.new(10, :hearts)
    nine_of_clubs = Card.new(9, :clubs)
    valid_stack = StackOfCards.new [ten_of_hearts, nine_of_clubs]

    eight_of_diamonds = Card.new(8,:diamonds)
    seven_of_spades = Card.new(7,:spades)
    valid_bottom_stack = StackOfCards.new [eight_of_diamonds,seven_of_spades]

    assert @v.can_append?(valid_stack,valid_bottom_stack)
  end

  def test_can_append_returns_false_if_stack_is_invalid
    ten_of_hearts = Card.new(10, :hearts)
    nine_of_clubs = Card.new(9, :clubs)
    valid_stack = StackOfCards.new [ten_of_hearts, nine_of_clubs]

    eight_of_diamonds = Card.new(8,:diamonds)
    seven_of_spades = Card.new(7,:diamonds)
    valid_bottom_stack = StackOfCards.new [eight_of_diamonds,seven_of_spades]

    assert !@v.can_append?(valid_stack,valid_bottom_stack)
  end

  def test_can_append_returns_false_if_invalid_append
    ten_of_hearts = Card.new(10, :hearts)
    nine_of_clubs = Card.new(9, :clubs)
    valid_stack = StackOfCards.new [ten_of_hearts, nine_of_clubs]

    eight_of_diamonds = Card.new(3,:diamonds)
    seven_of_spades = Card.new(2,:clubs)
    valid_bottom_stack = StackOfCards.new [eight_of_diamonds,seven_of_spades]

    assert !@v.can_append?(valid_stack,valid_bottom_stack)
  end
end
