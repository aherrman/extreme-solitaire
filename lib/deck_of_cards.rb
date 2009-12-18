require 'card'

# A deck of cards
class DeckOfCards
  include Enumerable

# ------------------------------------------------------------------------------
# :section: Construction
# ------------------------------------------------------------------------------

  # Creates a DeckOfCards.  The cards argument is an array of the Card objects
  # that make up the deck.
  def initialize(cards)
    @cards = cards.dup
    @standard = nil
  end

  # Creates a DeckOfCards containing a default deck.
  # The default deck is an unshuffled full standard deck.
  def DeckOfCards.default_deck
    cards = []
    Card::VALID_SUITS.each { |suit|
      Card::VALID_VALUES.each { |val|
        cards.push(Card.get val, suit)
      }
    }

    DeckOfCards.new(cards)
  end

  # Creates a DeckOfCards containing a shuffled version of the default deck
  def DeckOfCards.shuffled_deck(shuffles=1)
    d = DeckOfCards.default_deck
    d.shuffle!(shuffles)
    d
  end

# ------------------------------------------------------------------------------
# :section: Public functions
# ------------------------------------------------------------------------------

  # Gets the card at a given index
  def card(i)
    self[i]
  end

  # :call-seq:
  #   deck[index]
  #   deck[start, count]
  #   deck[range]
  #
  # Gets the cards a a given index or range
  # This works just like Array's [] operator
  def [](*args)
    @cards[*args]
  end

  # The top (first) card in the deck
  def top
    self[0]
  end

  # The bottom (last) card in the deck
  def bottom
    self[-1]
  end

  # The size of the deck
  def size
    @cards.size
  end

  # Checks if this deck is a "standard" deck.
  # A "standard" deck is one that has only one of each card.
  def is_standard_deck?
    return @standard if !@standard.nil?

    @standard = check_if_standard_deck?
  end

  # Checks if this deck is a full standard deck.  This means it has one of ever
  # valid card.
  def is_full_deck?
    is_standard_deck? && (size == 52)
  end

  # Creates a shuffled copy of the deck.  This is just like shuffle! but returns
  # a new deck instead of changing the deck it was called on.
  def shuffle(count=1)
    modify_dup(:shuffle!, count)[0]
  end

  # Creates a new deck by appending the contents of the passed deck to the end
  # of this one.
  def append_deck(d)
    modify_dup(:append_deck!, d)[0]
  end

  # Removes cards from the end of the deck, creating two new decks
  # This returns both the new deck and the old one
  #
  # ===Example
  #   d1 = DeckOfCards.default_deck
  #   newD1, poppedDeck = d1.remove_deck(4)
  def remove_deck(size=1)
    modify_dup(:remove_deck!, size)
  end

  # Creates a new Deck based on this one that has the last card popped from
  # the deck.  If the argument +n+ is provided then the last +n+ cards are
  # popped.
  #
  # This works like Array.pop except it returns a new version of the deck
  # instead of modifying the deck it was called on.
  #
  # This returns both the new deck and the popped cards
  #
  # ===Example
  #   d1 = DeckOfCards.default_deck
  #   newD1, poppedCards = d1.pop_deck(4)
  def pop_cards(n=1)
    modify_dup(:pop_cards!, n)
  end

  # :call-seq:
  #   push_cards(card1)
  #   push_cards(card1, card2, ...)
  #
  # Creates a new Deck based on this one that has the passed cards pushed to
  # the end of the deck.
  def push_cards(*args)
    modify_dup(:push_cards!, *args)[0]
  end

# ------------------------------------------------------------------------------
# :section: Mutating functions
# All functions in this section mutate the object it was called on
# ------------------------------------------------------------------------------

  # Shuffles the deck
  # You can optinally pass a shuffle count to this method, which will cause
  # it to shuffle the array that many times.  Generally this shouldn't be
  # required but is provided in case a single shuffle isn't "random" enough
  # for you
  def shuffle!(count=1)
    while(count > 0)
      @cards.shuffle!
      count -= 1
    end
  end

# ------------------------------------------------------------------------------
# :section: Enumerable support
# ------------------------------------------------------------------------------

  def each
    @cards.each { |o| yield o }
  end

# ------------------------------------------------------------------------------
# :section: Object overrides
# The following methods are overrides for built-in Object methods.  These
# overrides are to allow for proper equality checking, duplication, etc.
# ------------------------------------------------------------------------------

  # Checks if another deck is equal to this one
  def eql?(o)
    return false unless o.is_a?(DeckOfCards)
    @cards.eql? o.cards
  end

  # Checks if another object is equal to this one.
  # Normally == doesn't check the type, but for decks we're doing the check.
  def ==(o)
    eql? o
  end

  # Generates a unique hash for the deck
  def hash
    @cards.hash
  end

  # Duplicates the deck
  def dup
    # use self.class so that child classes don't have to override this just to
    # preserve the type
    self.class.new @cards
  end

# ------------------------------------------------------------------------------
# :section: Protected methods
# ------------------------------------------------------------------------------

protected
  # Checks to see if the deck is standard.
  def check_if_standard_deck?
    h = {}
    standard = true
    @cards.each { |c|
      if !h[c].nil?
        standard = false
        break;
      else
        h[c] = true
      end
    }

    standard
  end

  # The array of cards.  This is protected as only other decks should be able
  # to access it.  We don't want the collection publicly accessible as that
  # would make the deck mutable in ways we don't want
  def cards
    @cards
  end

  # Helper method for the immutable versions of the deck modify methods.
  # This duplicates the deck, calls the requested method on the new deck, then
  # returns the new deck
  #
  # Returns both the new array and the results returned by the method
  def modify_dup(method, *args)
    d = self.dup
    result = d.send(method, *args)
    [d, result]
  end

  # Pops the last card from the deck.  If the argument +n+ is provided then the
  # last +n+ cards are popped.  The removed cards are returned
  def pop_cards!(n=1)
    @cards.pop(n)
  end

  # :call-seq:
  #   push_cards!(card1)
  #   push_cards!(card1, card2, ...)
  #
  # Pushes cards to the end of the deck.
  def push_cards!(*args)
    @cards.push(*args)
  end

  # Appends the cards from the passed deck to the end of this deck.
  def append_deck!(d)
    @cards.push(*(d.cards))
  end

  # Pops cards from the end of the deck and returns them as a new deck
  def remove_deck!(n=1)
    DeckOfCards.new @cards.pop(n)
  end
end
