require 'stack_of_cards'
require 'foundation_validator'
require 'validated_stack'

# Represents one of the foundation (aces) stacks.
class Foundation < ValidatedStack

  # Initializes the Foundation with the given cards and suit
  def initialize(cards, suit)
    super(cards, FoundationValidator.get(suit))
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
