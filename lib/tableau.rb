require 'stack_of_cards'
require 'tableau_validator'
require 'validated_stack'

# Represents one of the columns (tableaus) on the solitaire board.
# This adds a stack of hidden cards along with the normal stack, and removes
# the top card from the hidden card when the validated stack is emptied.
class Tableau < ValidatedStack

  # Initializes the column from the set of cards.  If visible is nil then the
  # bottom card in the cards array/stack is made visible, and the rest are set
  # as the hidden cards
  def initialize(cards, visible=nil)

    if visible.nil?
      visible = cards[-1..-1]
      hidden = cards[0...-1]

      # If cards is empty then visible will be set to nil above
      visible = [] if visible.nil?
    else
      hidden = cards[0..-1]
      visible = visible[0..-1]
    end

    @hidden_cards = StackOfCards.new hidden
    super(visible, TableauStackValidator.get)
  end

  # The number of hidden cards left
  def num_hidden
    @hidden_cards.size
  end

  # Gets the display representation of the card at the given index.  This class
  # treats the hidden cards
  def card_display(i)
    if(i < @hidden_cards.size)
      Card::HIDDEN_CARD_STRING
    else
      Card.card_to_s(@cards[i - @hidden_cards.size])
    end
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
    Tableau.new @hidden_cards, @cards
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
end
