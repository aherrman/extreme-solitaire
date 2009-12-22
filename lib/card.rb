require 'simple_flyweight'

# A single playing card.
#
# This class extends the SimpleFlyweight module to allow for caching each card
# instance.  See SimpleFlyweight#get for usage.
class Card
  include Comparable

  extend SimpleFlyweight

# ------------------------------------------------------------------------------
# :section: Properties
# ------------------------------------------------------------------------------

  # The card's face value as a number <tt>(1 - 13)</tt>
  attr_reader :value

  # The card's suit.  See +VALID_SUITS+ for the list of accepted suits.
  attr_reader :suit

# ------------------------------------------------------------------------------
# :section: Constants
# ------------------------------------------------------------------------------

  # Card value that represents an Ace
  ACE=1

  # Card value that represents a Jack
  JACK=11

  # Card value that represents a Queen
  QUEEN=12

  # Card value that represents a King
  KING=13

  # The valid suits
  VALID_SUITS = [:hearts, :spades, :clubs, :diamonds]

  # The valid card values
  VALID_VALUES = (1..13).to_a

# ------------------------------------------------------------------------------
# :section: Construction
# ------------------------------------------------------------------------------

  # Constructs a Card.  card value and suit are validated and an exception will
  # be thrown if either are invalid.
  # See +VALID_SUITS+ and +VALID_VALUES+ for the valid values
  #
  # Generally you should use Card.get instead of Card.new
  def initialize(card_value, card_suit)
    fail "Invalid suit: #{card_suit}" unless validate_suit(card_suit)
    fail "Invalid value: #{card_value}" unless validate_value(card_value)
    @value = card_value
    @suit = card_suit
  end

# ------------------------------------------------------------------------------
# :section: Object overrides
# The following methods are overrides for built-in Object methods.  These
# overrides are to allow for proper equality checking, duplication, etc.
# ------------------------------------------------------------------------------

  # Duplicates the Card
  def dup
    Card.new @value, @suit
  end

  # Checks if another Card is equal to this one
  def eql?(o)
    return false unless o.is_a?(Card)
    o.value == @value && o.suit == @suit
  end

  # Checks if another object's properties are equal to this one's.  This does
  # *not* check the type.
  def ==(o)
    return true if equal?(0)

    begin
      return o.value == @value && o.suit == @suit
    rescue Exception => ex
      return false
    end
  end

  # Generates a unique hash for the Card
  def hash
    @value.hash ^ @suit.hash
  end

  # Simple string representation of the card
  def to_s
    "#{value} of #{suit}"
  end

  # Compares this card to another.  This *only* compares the card value.  The
  # suit is ignored.
  #
  # Returns <tt>-1</tt> for less, <tt>0</tt> for equal, and <tt>1</tt> for the
  # greater.
  def <=>(other)
    @value <=> other.value
  end

# ------------------------------------------------------------------------------
# :section: Protected methods
# ------------------------------------------------------------------------------

protected
  # Validates a suit.
  #
  # Returns +true+ if the suit is valid, +false+ otherwise
  def validate_suit(c)
    Card::VALID_SUITS.include?(c)
  end

  # Validates a value.
  #
  # Returns +true+ if the value is valid, +false+ otherwise
  def validate_value(v)
    Card::VALID_VALUES.include?(v)
  end
end
