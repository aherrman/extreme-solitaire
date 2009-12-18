require "deck_of_cards.rb"

# DeckOfCards that enforces the rules of solitaire on modifications
class SolitaireStack < DeckOfCards

# ------------------------------------------------------------------------------
# :section: Class Methods
# ------------------------------------------------------------------------------

  # Checks if two cards are sequential (alternating black/red suits and
  # top's valie is 1 + bottom's value)
  def self.are_cards_sequential?(top, bottom)
    return false unless top.value > 2 # Aces can't be placed on the stack
    return false unless top.value == (bottom.value + 1)
    is_valid_suit_transition(top.suit, bottom.suit)
  end

  # Checks to see if a suit transition is valid
  def self.is_valid_suit_transition(s1, s2)
    VALID_SUIT_TRANSITIONS[s1].include?(s2)
  end

  # Checks to see if two stacks can be merged based on the rules of Solitaire.
  # This allows for normal DeckOfCards objects to be passed in.  If they are
  # then they will be validated before checking if they can be appended
  def self.can_stacks_be_merged?(top, bottom)
    if !top.is_a?(SolitaireStack)
      return false unless SolitaireStack.is_valid_stack?(top)
    end
    if !bottom.is_a?(SolitaireStack)
      return false unless SolitaireStack.is_valid_stack?(bottom)
    end
    are_cards_sequential?(top.bottom, bottom.top)
  end

  # Checks to see if the passed deck is a valid Solitaire stack
  def self.is_valid_stack?(d)
    return false if d[0].value == 1

    prev = nil
    valid = true

    d.each { |card|
      if !(prev.nil?)
        valid = SolitaireStack.are_cards_sequential?(prev, card)
        break unless valid
      end
      prev = card
    }

    valid
  end

# ------------------------------------------------------------------------------
# :section: Construction
# ------------------------------------------------------------------------------

  # Initializes the stack just like the normal DeckOfCards, but also validates
  # that the deck is a valid solitaire stack (alternating black/red suits and
  # values decreasing by 1 every time)
  def initialize(cards)
    super(cards)
    raise "Invalid stack!" unless SolitaireStack.is_valid_stack?(self)
  end

# ------------------------------------------------------------------------------
# :section: Public Methods
# ------------------------------------------------------------------------------

  # Checks to see if the given stack can be merged (appended to the end) with
  # this one based on the rules of Solitaire.
  def can_append?(stack)
    SolitaireStack.can_stacks_be_merged?(self, stack)
  end

  # Checks to see if an individual card can be appended
  def can_append_card?(card)
    SolitaireStack.are_cards_sequential?(self.bottom, card)
  end

  # Like DeckOfCards#pushCards but makes sure the cards being pushed make a
  # valid stack and can be pushed without breaking the solitaire rules
  def push_cards(*args)
    to_push = SolitaireStack.new args
    append_deck(to_push)
  end

  # Like DeckOfCards#append_deck but makes sure deck is valid and can be
  # appended without breaking the rules of solitaire
  def append_deck(d)
    raise "Invalid append!" unless can_append?(d)
    super(d)
  end

  # Raises an error as shuffle is not supported on solitaire stacks
  def shuffle(count=1)
    raise "Solitaire Stacks cannot be shuffled!"
  end

  # Raises an error as shuffle is not supported on solitaire stacks
  def shuffle!(count=1)
    raise "Solitaire Stacks cannot be shuffled!"
  end

protected

# ------------------------------------------------------------------------------
# :section: Protected Data
# ------------------------------------------------------------------------------

  # The valid suit transitions
  VALID_SUIT_TRANSITIONS = { :hearts => [:clubs, :spades],
    :diamonds => [:clubs, :spades],
    :clubs => [:hearts, :diamonds],
    :spades => [:hearts, :diamonds] }

end
