require 'card'

# A stack of cards
class StackOfCards
  include Enumerable

# ------------------------------------------------------------------------------
# :section: Construction
# ------------------------------------------------------------------------------

  # Creates a StackOfCards.  The cards argument is an array of the Card objects
  # that make up the stack.
  def initialize(cards)
    if cards.is_a?(Array)
      @cards = cards.dup
    else
      @cards = cards.to_a
    end
  end

  # Creates a StackOfCards containing a default stack.
  # The default stack is an unshuffled full standard stack.
  def StackOfCards.default_stack
    cards = []
    Card::VALID_SUITS.each { |suit|
      Card::VALID_VALUES.each { |val|
        cards.push(Card.get val, suit)
      }
    }

    StackOfCards.new(cards)
  end

  # Creates a StackOfCards containing a shuffled version of the default stack
  def StackOfCards.shuffled_stack(shuffles=1)
    d = StackOfCards.default_stack
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
  #   stack[index]
  #   stack[start, count]
  #   stack[range]
  #
  # Gets the cards a a given index or range
  # This works just like Array's [] operator
  def [](*args)
    @cards[*args]
  end

  # The top (first) card in the stack
  def top
    self[0]
  end

  # The bottom (last) card in the stack
  def bottom
    self[-1]
  end

  # The size of the stack
  def size
    @cards.size
  end

  # Creates a shuffled copy of the stack.  This is just like shuffle! but returns
  # a new stack instead of changing the stack it was called on.
  def shuffle(count=1)
    modify_dup(:shuffle!, count)[0]
  end

  # Creates a new stack by appending the contents of the passed stack to the end
  # of this one.
  def append_stack(d)
    modify_dup(:append_stack!, d)[0]
  end

  # Creates a new stack by pushing the passed card to the end of this one.
  def append_card(c)
    modify_dup(:append_card!, c)[0]
  end

  # Removes cards from the end of the stack, creating two new stacks
  # This returns both the new stack and the old one
  #
  # ===Example
  #   d1 = StackOfCards.default_stack
  #   newD1, poppedDeck = d1.remove_stack(4)
  def remove_stack(size=1)
    modify_dup(:remove_stack!, size)
  end

  # Creates a new stack by removing the last card from the end.  This returns
  # both the new stack and the removed card.
  #
  # ===Example
  #   s = StackOfCards.default_stack
  #   new_stack, card = s.remove_card
  def remove_card
    modify_dup(:remove_card!)
  end

  # Returns the stack as an array of cards
  def to_a
    @cards.dup
  end

# ------------------------------------------------------------------------------
# :section: Mutating functions
# All functions in this section mutate the object it was called on
# ------------------------------------------------------------------------------

  # Shuffles the stack
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

  # Checks if another stack is equal to this one
  def eql?(o)
    return false unless o.is_a?(self.class)
    @cards.eql? o.cards
  end

  # Checks if another object is equal to this one.
  # Normally == doesn't check the type, but for stacks we're doing the check.
  def ==(o)
    eql? o
  end

  # Generates a unique hash for the stack
  def hash
    @cards.hash
  end

  # Duplicates the stack
  def dup
    # use self.class so that child classes don't have to override this just to
    # preserve the type
    self.class.new @cards
  end

# ------------------------------------------------------------------------------
# :section: Protected methods
# ------------------------------------------------------------------------------

protected
  # The array of cards.  This is protected as only other stacks should be able
  # to access it.  We don't want the collection publicly accessible as that
  # would make the stack mutable in ways we don't want
  def cards
    @cards
  end

  # Helper method for the immutable versions of the stack modify methods.
  # This duplicates the stack, calls the requested method on the new stack, then
  # returns the new stack
  #
  # Returns both the new array and the results returned by the method
  def modify_dup(method, *args)
    d = self.dup
    result = d.send(method, *args)
    [d, result]
  end

  # Appends the cards from the passed stack to the end of this stack.
  def append_stack!(d)
    @cards.push(*(d.cards))
  end

  # Pushes a single card onto the stack
  def append_card!(c)
    @cards.push(c)
  end

  # Removes a single card from the end of the stack
  def remove_card!
    @cards.pop
  end

  # Pops cards from the end of the stack and returns them as a new stack
  def remove_stack!(n=1)
    StackOfCards.new @cards.pop(n)
  end
end
