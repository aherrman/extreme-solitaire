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
        cards.push(Card.new val, suit)
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
    @cards[i]
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
    modify_dup(:shuffle!, count)
  end

  # Creates a new Deck that has the card at the given index removed.  If
  # the +count+ argument is provided then that many elements starting from the
  # index will be removed
  def remove_cards(index, count=1)
    modify_dup(:remove_cards!, index, count)
  end

  # :call-seq:
  #   insert_cards(index, card)
  #   insert_cards(index, card1, card2, ...)
  #
  # Creates a new Deck based on the current one that has the given card(s) added
  # at the requested position
  def insert_cards(index, *args)
    modify_dup(:insert_cards!, index, *args)
  end

  # Creates a new Deck based on this one that has the last card popped from
  # the deck.  If the argument +n+ is provided then the last +n+ cards are
  # popped.
  #
  # This works like Array.pop except it returns a new version of the deck
  # instead of modifying the deck it was called on.
  def pop_cards(n=1)
    modify_dup(:pop_cards!, n)
  end

  # :call-seq:
  #   push_cards(card1)
  #   push_cards(card1, card2, ...)
  #
  # Creates a new Deck based on this one that has the passed cards pushed to
  # the end of the deck.
  #
  # This works like Array.push except it returns a new version of the deck
  # instead of modifying the deck it was called on.
  def push_cards(*args)
    modify_dup(:push_cards!, *args)
  end

  # Creates a new Deck based on this one that has the first card removed from
  # the deck.  If the argument +n+ is provided then the last +n+ cards are
  # removed.
  #
  # This works like Array.shift except it returns a new version of the deck
  # instead of modifying the deck it was called on.
  def shift_cards(n=1)
    modify_dup(:shift_cards!, n)
  end

  # :call-seq:
  #   unshift_cards(card1)
  #   unshift_cards(card1, card2, ...)
  #
  # Creates a new Deck based on this one that has the passed cards added to
  # the beginning of the deck.
  #
  # This works like Array.unshift except it returns a new version of the deck
  # instead of modifying the deck it was called on.
  def unshift_cards(*args)
    modify_dup(:unshift_cards!, *args)
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

  # Removes the card at index +i+ from the deck.
  def remove_cards!(index, count=1)
    @cards.slice!(index, count)
  end

  # :call-seq:
  #   insert_cards!(index, card)
  #   insert_cards!(index, card1, card2, ...)
  #
  # Inserts a card at index +i+ in the deck.
  def insert_cards!(i, *args)
    @cards.insert(i, *args)
  end

  # Pops the last card from the deck.  If the argument +n+ is provided then the
  # last +n+ cards are popped.
  # This works just like Array.pop
  def pop_cards!(n=1)
    @cards.pop(n)
  end

  # :call-seq:
  #   push_cards!(card1)
  #   push_cards!(card1, card2, ...)
  #
  # Pushes cards to the end of the deck.
  # This works just like Array.push
  def push_cards!(*args)
    @cards.push(*args)
  end

  # Shifts the first card from the deck.  If the argument +n+ is provided then
  # the first +n+ cards are removed.
  # This works just like Array.shift
  def shift_cards!(n=1)
    @cards.shift(n)
  end

  # :call-seq:
  #   unshift_cards!(card1)
  #   unshift_cards!(card1, card2, ...)
  #
  # Adds cards to the beginning of the deck
  # This works just like Array.unshift
  def unshift_cards!(*args)
    @cards.unshift(*args)
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
    DeckOfCards.new @cards
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
  def modify_dup(method, *args)
    d = self.dup
    d.send(method, *args)
    d
  end
end
