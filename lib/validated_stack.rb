require "stack_of_cards.rb"

# Stack implementation that validates the stack based on the rules provided in
# the passed validator.
#
# The validator is expected to have the following methods:
#
# * can_append?(top_stack, bottom_stack)
# * can_append_card?(stack, card)
# * is_valid_stack?(stack)
class ValidatedStack < StackOfCards
  # The validator used to validate this stack
  attr_reader :validator

  # Whether or not shuffing is allowed for this stack
  attr_reader :can_shuffle

  # Initializes the stack to use the given validator.
  # This will raise an error if validator is nil
  def initialize(cards, validator, can_shuffle=false)
    super(cards)
    raise "No validator provided" if validator.nil?

    @validator = validator
    @can_shuffle = can_shuffle
    raise "Invalid Stack" unless valid?
  end

  # Raises an error if the stack cannot be shuffled
  def shuffle(count=1)
    raise "This stack cannot be shuffled" unless @can_shuffle
    super(count)
  end

  # Raises an error if the stack cannot be shuffled
  def shuffle!(count=1)
    raise "This stack cannot be shuffled" unless @can_shuffle
    super(count)
  end

  # Checks to see if the given stack can be merged (appended to the end) with
  # this one based on the rules of the validator.
  def can_append?(stack)
    @validator.can_append?(self, stack)
  end

  # Checks to see if an individual card can be appended
  def can_append_card?(card)
    @validator.can_append_card?(self, card)
  end

  # Like StackOfCards#append_stack but makes sure stack is valid and can be
  # appended without breaking the rules of the validator
  def append_stack(s)
    raise "Invalid append!" unless can_append?(s)
    super(s)
  end

  # Like StackOfCards#append_card but makes sure stack is valid and can be
  # appended without breaking the rules of the validator
  def append_card(c)
    raise "Invalid append!" unless can_append_card?(c)
    super(c)
  end

# ------------------------------------------------------------------------------
# :section: Object overrides
# The following methods are overrides for built-in Object methods.  These
# overrides are to allow for proper equality checking, duplication, etc.
# ------------------------------------------------------------------------------

  # Checks if another stack is equal to this one
  def eql?(o)
    return false unless o.is_a?(self.class)
    (@cards.eql? o.cards) && (@validator.eql? o.validator)
  end

  # Generates a unique hash for the stack
  def hash
    @cards.hash ^ @validator.hash
  end

  # Creates a duplicate of this stack
  def dup
    ValidatedStack.new @cards, @validator
  end

# ------------------------------------------------------------------------------
# :section: Protected methods
# ------------------------------------------------------------------------------

protected
  def valid?
    @validator.is_valid_stack?(self)
  end
end
