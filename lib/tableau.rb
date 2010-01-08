require 'stack_of_cards'
require 'tableau_validator'
require 'validated_stack'

# Represents one of the columns (tableaus) on the solitaire board.
# This adds a stack of hidden cards along with the normal stack, and removes
# the top card from the hidden card when the validated stack is emptied.
class Tableau < ValidatedStack

  # Initializes the column from the set of cards.  The bottom card is made
  # visible, and the rest are set as the hidden cards
  def initialize(cards)
    if cards.empty?
      hidden = []
      visible = []
    else
      top_card = cards[-1]

      hidden = cards[0...-1]
      visible = [top_card]
    end

    @hidden_cards = StackOfCards.new hidden
    super(visible, TableauStackValidator.get)
  end

  # The number of hidden cards left
  def num_hidden
    @hidden_cards.size
  end

  def can_append_card?(card)
    if size == 0 && @hidden_cards.empty?
      return true if card.value == Card::KING
      return false
    end
    super(card)
  end

  def can_append?(stack)
    top = stack.top

    if size == 0 && @hidden_cards.empty?
      return true if top.value == Card::KING
      return false
    end

    super(stack)
  end

# ------------------------------------------------------------------------------
# :section: Mutating functions
# These are the methods that mutate the object
# ------------------------------------------------------------------------------
  def update_from_hidden_if_empty!
    if size == 0 && !@hidden_cards.empty?
      append_card!(@hidden_cards.remove_card!)
    end
  end

# ------------------------------------------------------------------------------
# :section: Object overrides
# The following methods are overrides for built-in Object methods.  These
# overrides are to allow for proper equality checking, duplication, etc.
# ------------------------------------------------------------------------------

  # Creates a duplicate of this stack
  def dup
    d = Tableau.new []
    d.set_data(@hidden_cards, @cards)
    d
  end

  # Checks if another stack is equal to this one
  def eql?(o)
    return false unless o.is_a?(self.class)
    (@cards.eql? o.cards) && (@validator.eql? o.validator) &&
        (@hidden_cards.eql? o.hidden_cards)
  end

  # Generates a unique hash for the stack
  def hash
    super() ^ @hidden_cards.hash
  end

# ------------------------------------------------------------------------------
# :section: Protected methods
# ------------------------------------------------------------------------------
protected
  def hidden_cards
    @hidden_cards
  end

  def set_data(hidden_cards, visible_cards)
    @hidden_cards = hidden_cards.dup
    @cards = visible_cards.dup
  end
end
