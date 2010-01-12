require 'validated_stack'
require 'foundation'
require 'tableau'
require 'immutable_proxy'

# The solitaire board
class SolitaireBoard

# ------------------------------------------------------------------------------
# :section: Construction
# ------------------------------------------------------------------------------

  # Builds a board from a deck of cards
  def self.build_from_deck(deck)
    state = Hash.new

    tableaus = []

    (1..7).each do |i|
      deck, stack = deck.remove_stack(i)

      tableaus.push Tableau.new stack
    end

    unused_waste = deck

    state[:tableaus] = tableaus
    state[:unused_waste] = unused_waste

    SolitaireBoard.new state
  end

  # Initializes the board from a set board state.  The state is a hashtable
  # containing all the various pieces of state for the board.  Any expected
  # state that isn't provided in the hashtable will be initialized to its
  # defaults (generally an empty stack).
  #
  # The following properties can be added to the state hash for initialization:
  #
  # [:diamonds_foundation] The diamonds foundation (aces stack)
  # [:hearts_foundation] The hearts foundation (aces stack)
  # [:clubs_foundation] The clubs foundation (aces stack)
  # [:spades_foundation] The spades foundation (aces stack)
  # [:tableaus] Array of all the tableaus (columns).
  #             Only the first 7 entries in the array will be used.
  # [:unused_waste] The unused waste pile (stack of cards)
  # [:used_waste] The used waste pile (stack of cards)
  # [:turn_count] The number of turns that have happened so far
  def initialize(state=nil)
    @diamonds_foundation = get_state(state, :diamonds_foundation) {
      Foundation.new [], :diamonds
    }
    @hearts_foundation = get_state(state, :hearts_foundation) {
      Foundation.new [], :hearts
    }
    @clubs_foundation = get_state(state, :clubs_foundation) {
      Foundation.new [], :clubs
    }
    @spades_foundation = get_state(state, :spades_foundation) {
      Foundation.new [], :spades
    }

    init_tab = get_state(state, :tableaus) { [] }

    @tableaus = []

    (0..6).each do |i|
      @tableaus.push get_state(init_tab, i) {
        Tableau.new []
      }
    end

    @unused_waste = get_state(state, :unused_waste) {
      StackOfCards.new []
    }
    @used_waste = get_state(state, :used_waste) {
      StackOfCards.new []
    }

    @turn_count = get_state(state, :turn_count) { 0 }
  end

# ------------------------------------------------------------------------------
# :section: Board state accessors
# ------------------------------------------------------------------------------

  # The number of turns that have been made so far
  attr_reader :turn_count

  # Gets one of the columns (tableaus) by index.  Returned tableau is immutable
  def get_tableau(i)
    tableau = @tableaus[i]
    return nil if tableau.nil?
    ImmutableProxy.new tableau
  end

  # The card at the top of the used waste pile
  def top_waste_card
    # The usable waste card is actually the one on the bottom of the used pile,
    # since appends/removes happen at the bottom.
    @used_waste.bottom
  end

  # The number of cards in the unused waste pile
  def num_unused_waste_cards
    @unused_waste.size
  end

  # The number of cards in the used waste pile
  def num_used_waste_cards
    @used_waste.size
  end

  # The diamonds foundation (aces stack).  Returned stack is immutable
  def diamonds_foundation
    ImmutableProxy.new @diamonds_foundation
  end

  # The hearts foundation (aces stack).  Returned stack is immutable
  def hearts_foundation
    ImmutableProxy.new @hearts_foundation
  end

  # The clubs foundation (aces stack).  Returned stack is immutable
  def clubs_foundation
    ImmutableProxy.new @clubs_foundation
  end

  # The spades foundation (aces stack).  Returned stack is immutable
  def spades_foundation
    ImmutableProxy.new @spades_foundation
  end

# ------------------------------------------------------------------------------
# :section: Misc Public Methods
# ------------------------------------------------------------------------------

  # Checks to see if another board is equal to this one in every way except for
  # the turn count.  Usefulf for seeing if a particular board configuration has
  # been seen before.
  def eql_except_for_turn_count?(board)
    check_equal(board, :@diamonds_foundation) &&
    check_equal(board, :@clubs_foundation) &&
    check_equal(board, :@spades_foundation) &&
    check_equal(board, :@hearts_foundation) &&
    check_equal(board, :@unused_waste) &&
    check_equal(board, :@used_waste) &&
    check_equal(board, :@tableaus)
  end

# ------------------------------------------------------------------------------
# :section: Turn handling
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# :section: Object overrides
# The following methods are overrides for built-in Object methods.  These
# overrides are to allow for proper equality checking, duplication, etc.
# ------------------------------------------------------------------------------

  def dup
    state = {
      :diamonds_foundation => @diamonds_foundation.dup,
      :clubs_foundation => @clubs_foundation.dup,
      :spades_foundation => @spades_foundation.dup,
      :hearts_foundation => @hearts_foundation.dup,
      :tableaus => @tableaus.map { |tableau| tableau.dup },
      :unused_waste => @unused_waste.dup,
      :used_waste => @used_waste.dup,
      :turn_count => @turn_count
    }

    SolitaireBoard.new state
  end

  def eql?(board)
    @turn_count == board.turn_count && eql_except_for_turn_count?(board)
  end

  def ==(board)
    eql? board
  end

  def hash
    value = 0
    value ^= @diamonds_foundation.hash
    value ^= @clubs_foundation.hash
    value ^= @spades_foundation.hash
    value ^= @hearts_foundation.hash
    value ^= @unused_waste.hash
    value ^= @used_waste.hash
    value ^= @tableaus.hash
    value ^= @turn_count.hash
    value
  end

  def to_s
    "Solitaire Board: #{hash}"
  end

  def inspect
    s = ""
    s << Card.card_to_s(@diamonds_foundation.bottom, true)
    s << "  "
    s << Card.card_to_s(@clubs_foundation.bottom, true)
    s << "  "
    s << Card.card_to_s(@hearts_foundation.bottom, true)
    s << "  "
    s << Card.card_to_s(@spades_foundation.bottom, true)
    s << "  - "
    s << Card.card_to_s(top_waste_card, true)
    s << " / "
    s << "(#{num_unused_waste_cards})"
    s << "\n\n"

    max_cards = @tableaus.inject(0) do |max, tableau|
      count = tableau.num_hidden + tableau.size
      count > max ? count : max
    end

    (0...max_cards).each do |card_index|
      @tableaus.each do |tableau|
        s << tableau.card_display(card_index)
        s << "  "
      end
      s << "\n"
    end

    s
  end

# ------------------------------------------------------------------------------
# :section: Private functions
# ------------------------------------------------------------------------------
private

  # Use to check the equality of private variables in this class and the
  # provided class.  This is provided for getting access to another board's
  # private data that doesn't have a public getter without having to define
  # private accessors for each.
  def check_equal(other, variable)
    mine = instance_variable_get(variable)
    theirs = other.instance_variable_get(variable)
    mine.eql? theirs
  end

  # Gets a state value from the state hash.  If no value with the given ID is
  # found (returns nil) and a block was provided then the block will be run and
  # its return value used.
  def get_state(state, id, &block)
    s = state[id] unless state.nil?
    return s unless s.nil?

    yield block unless block.nil?
  end

end
