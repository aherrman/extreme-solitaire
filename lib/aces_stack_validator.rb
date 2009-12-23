require "card.rb"
require "simple_flyweight.rb"

#Validator for the Aces stacks
class AcesStackValidator
  # Extend flyweight so that we only have to construct one validator per type.
  extend SimpleFlyweight

  # The suit this validator allows
  attr_reader :suit

  # Initializes the validator for the given suit.  Generally you should use
  # AcesStackValidator.get instead of constructing new instances.
  def initialize(suit)
    raise "Suit cannot be nil" if suit.nil?
    raise "Unknown suit" unless Card::VALID_SUITS.include?(suit)
    @suit = suit
  end

  def is_valid_stack?(stack)
    return false unless stack[0].suit == @suit

    prev = nil
    valid = true

    stack.each do |card|
      if !prev.nil?
        valid = is_valid_transition?(prev, card)
      end

      prev = card
      break unless valid
    end

    valid
  end

  def can_append_card?(stack, card)
    is_valid_transition?(stack.bottom, card)
  end

  def can_append?(top_stack, bottom_stack)
    return false unless is_valid_stack? top_stack
    return false unless is_valid_stack? bottom_stack

    is_valid_transition? top_stack.bottom, bottom_stack.top
  end

protected
  def is_valid_transition?(top, bottom)
    if top.nil?
      return true if bottom.value == Card::ACE && bottom.suit == @suit
      return false
    end

    (top.suit == @suit) && (bottom.suit == @suit) &&
        (top.value == bottom.value - 1)
  end
end
