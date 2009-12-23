$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'stack_of_cards'
require 'aces_stack_validator'

class AcesStackValidatorTest < Test::Unit::TestCase

  def setup
    @v = AcesStackValidator.get :diamonds
  end

  def test_get_returns_same_instance_every_time
    v1 = AcesStackValidator.get :spades
    v2 = AcesStackValidator.get :spades

    assert_equal v1, v2
    assert v1.equal?(v2)
  end

  def test_is_valid_stack_returns_false_if_invalid_transition
    c1 = Card.new(1, :hearts)
    c2 = Card.new(2, :clubs)
    invalid_stack = StackOfCards.new [c1, c2]

    assert ! @v.is_valid_stack?(invalid_stack)
  end

  def test_is_valid_stack_returns_false_if_invalid_suit
    c1 = Card.new(1, :clubs)
    c2 = Card.new(2, :clubs)
    invalid_stack = StackOfCards.new [c1, c2]

    assert ! @v.is_valid_stack?(invalid_stack)
  end

  def test_is_valid_returns_true_if_valid
    c1 = Card.new(1, :diamonds)
    c2 = Card.new(2, :diamonds)
    valid_stack = StackOfCards.new [c1, c2]

    assert @v.is_valid_stack?(valid_stack)
  end

  def test_can_append_card_returns_true_if_valid
    c1 = Card.new(1, :diamonds)
    c2 = Card.new(2, :diamonds)
    s = StackOfCards.new [c1, c2]

    c3 = Card.new(3, :diamonds)
    assert @v.can_append_card?(s, c3)
  end

  def test_can_append_card_returns_false_if_wrong_value
    c1 = Card.new(1, :diamonds)
    c2 = Card.new(2, :diamonds)
    s = StackOfCards.new [c1, c2]

    c3 = Card.new(4, :diamonds)
    assert !@v.can_append_card?(s, c3)
  end

  def test_can_append_card_returns_false_if_wrong_suit
    c1 = Card.new(1, :diamonds)
    c2 = Card.new(2, :diamonds)
    s = StackOfCards.new [c1, c2]

    c3 = Card.new(3, :clubs)
    assert !@v.can_append_card?(s, c3)
  end

  def test_can_append_if_stack_is_valid
    ten_of_hearts = Card.new(1, :diamonds)
    nine_of_clubs = Card.new(2, :diamonds)
    valid_stack = StackOfCards.new [ten_of_hearts, nine_of_clubs]

    eight_of_diamonds = Card.new(3,:diamonds)
    seven_of_spades = Card.new(4,:diamonds)
    valid_bottom_stack = StackOfCards.new [eight_of_diamonds,seven_of_spades]

    assert @v.can_append?(valid_stack,valid_bottom_stack)
  end

  def test_can_append_ace_to_empty_stack
    empty_stack = StackOfCards.new []

    c1 = Card.new(1,:diamonds)

    assert @v.can_append_card?(empty_stack, c1)
  end

  def test_cannot_append_non_ace_to_empty_stack
    empty_stack = StackOfCards.new []

    c1 = Card.new(2,:diamonds)

    assert !@v.can_append_card?(empty_stack, c1)
  end

  def test_can_append_returns_false_if_stack_is_invalid
    ten_of_hearts = Card.new(1, :diamonds)
    nine_of_clubs = Card.new(2, :diamonds)
    valid_stack = StackOfCards.new [ten_of_hearts, nine_of_clubs]

    eight_of_diamonds = Card.new(3,:diamonds)
    seven_of_spades = Card.new(4,:clubs)
    valid_bottom_stack = StackOfCards.new [eight_of_diamonds,seven_of_spades]

    assert !@v.can_append?(valid_stack,valid_bottom_stack)
  end

  def test_can_append_returns_false_if_bad_append
    ten_of_hearts = Card.new(1, :diamonds)
    nine_of_clubs = Card.new(2, :diamonds)
    valid_stack = StackOfCards.new [ten_of_hearts, nine_of_clubs]

    eight_of_diamonds = Card.new(6,:diamonds)
    seven_of_spades = Card.new(7,:diamonds)
    valid_bottom_stack = StackOfCards.new [eight_of_diamonds,seven_of_spades]

    assert !@v.can_append?(valid_stack,valid_bottom_stack)
  end
end
