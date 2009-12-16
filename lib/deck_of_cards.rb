require 'card'

# A deck of cards
class DeckOfCards
  include Enumerable

  # Creates a DeckOfCards.  The cards argument is an array of the Card objects
  # that make up the deck.
  def initialize(cards)
    @cards = cards.dup
    @standard = nil
  end

  # Gets the card at a given index
  def card(i)
    @cards[i]
  end

  # The size of the deck
  def size
    @cards.size
  end

  def each
    @cards.each { |o| yield o }
  end

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

  def shuffle(count=1)
    d = DeckOfCards.new(@cards)
    d.shuffle!(count)

    d
  end

  def shuffle!(count=1)
    while(count > 0)
      @cards.shuffle!
      count -= 1
    end
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
end
