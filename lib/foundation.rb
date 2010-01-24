require 'stack_of_cards'
require 'foundation_validator'
require 'validated_stack'

# Represents one of the foundation (aces) stacks.
class Foundation < ValidatedStack

  # Shortcut for building a foundation.  Creates a foundation with all cards up
  # and including the value passed in.
  def self.build_foundation(upto, suit)
    a = (1..upto).inject([]) { |a, val|
      a << Card.get(val, suit)
    }
    Foundation.new a, suit
  end

  # Initializes the Foundation with the given cards and suit
  def initialize(cards, suit)
    super(cards, FoundationValidator.get(suit))
  end

  # The foundation's suit
  def suit
    @validator.suit
  end

# ------------------------------------------------------------------------------
# :section: Object overrides
# The following methods are overrides for built-in Object methods.  These
# overrides are to allow for proper equality checking, duplication, etc.
# ------------------------------------------------------------------------------

  # Creates a duplicate of this stack
  def dup
    Foundation.new @cards, @validator.suit
  end
end
