require 'validated_stack'
require 'foundation'
require 'tableau'
require 'immutable_proxy'
require 'eql_helper'
require 'hash_helper'
require 'turn/tableau_to_foundation_turn'
require 'turn/tableau_to_tableau_turn'
require 'turn/waste_to_tableau_turn'
require 'turn/waste_to_foundation_turn'
require 'turn/foundation_to_tableau_turn'
require 'turn/flip_stock_turn'

# Error used by the board to indicate an invalid move was attempted
class InvalidMoveError < RuntimeError
end

# The solitaire board
class SolitaireBoard
  include EqlHelper
  include HashHelper

  # Whether the board is in the middle of a move (needs finalizing) or not.
  attr_reader :moving

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

    stock = deck

    state[:tableaus] = tableaus
    state[:stock] = stock

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
  # [:stock] The stock of cards left in the deck (stack of cards)
  # [:waste] The waste pile (stack of cards)
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

    @stock = get_state(state, :stock) {
      StackOfCards.new []
    }
    @waste = get_state(state, :waste) {
      StackOfCards.new []
    }

    @turn_count = get_state(state, :turn_count) { 0 }
    @moving = false
    @next_waste_card = nil
  end

# ------------------------------------------------------------------------------
# :section: Board state accessors
# ------------------------------------------------------------------------------

  # The number of turns that have been made so far
  attr_reader :turn_count

  # Gets the visible cards in one of the tableaus.
  def get_tableau_cards(i)
    tableau = @tableaus[i]
    return nil if tableau.nil?

    # We copy the tableau into a standard stack so that the hidden cards cannot
    # be seen by the player.
    StackOfCards.new tableau
  end

  # Gets the number of hidden cards in a tableau
  def get_num_hidden_cards_for_tableau(i)
    tableau = @tableaus[i]
    return 0 if tableau.nil?
    tableau.num_hidden
  end

  # The total number of hidden cards across all tableaus
  def num_hidden
    @tableaus.inject(0) { |sum, tableau|
      sum + tableau.num_hidden
    }
  end

  # The card at the top of the waste pile
  def top_waste_card
    # The usable waste card is actually the one on the bottom of the used pile,
    # since appends/removes happen at the bottom.
    @waste.bottom
  end

  # The number of cards in the stock pile
  def num_stock_cards
    @stock.size
  end

  # The number of cards in the waste pile
  def num_waste_cards
    @waste.size
  end

  # The top card in the diamonds foundation.
  def diamonds_foundation_top
    # All stacks move down, but the foundations are viewed differently, so the
    # visible card is actually the bottom one.
    @diamonds_foundation.bottom
  end

  # The top card in the hearts foundation.
  def hearts_foundation_top
    @hearts_foundation.bottom
  end

  # The top card in the clubs foundation.
  def clubs_foundation_top
    @clubs_foundation.bottom
  end

  # The top card in the spades foundation.
  def spades_foundation_top
    @spades_foundation.bottom
  end

  # True if the board is solved (all cards are in the foundations), false
  # otherwise
  def solved?
    # We're assuming no invalid boards, but that makes this easier.
    # If you make an invalid board then that's ALL YOUR FAULT and I don't care
    # if this is wrong.  :)
    @diamonds_foundation.size == 13 && @spades_foundation.size == 13 &&
        @hearts_foundation.size == 13 && @clubs_foundation.size == 13
  end

# ------------------------------------------------------------------------------
# :section: Misc Public Methods
# ------------------------------------------------------------------------------

  # Checks to see if another board is equal to this one.  Unlike eql? this
  # includes the turn count in the check.
  def eql_including_turn_count?(board)
    @turn_count == board.turn_count && eql?(board)
  end

  def to_display_string
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
    s << "(#{num_stock_cards})"
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
# :section: Turn handling
# ------------------------------------------------------------------------------

  # Gets a list of all the valid turns that can be applied to the current
  # board.
  def get_turns
    get_tableau_turns + get_foundation_turns + get_stock_turns + get_waste_turns
  end

  # Gets the possible turns involving moving the top waste card.
  def get_waste_turns
    turns = []
    card = top_waste_card

    return turns if card.nil?

    begin
      foundation = get_foundation_for_move(card.suit)
      if foundation.can_append_card? card
        turns << WasteToFoundationTurn.new(self)
      end
    rescue
      # Ignore the exception, we'll just move on to other possible turns
    end

    @tableaus.each_index do |tableau_index|
      tableau = @tableaus[tableau_index]
      if tableau.can_append_card? card
        turns << WasteToTableauTurn.new(self, tableau_index)
      end
    end

    turns
  end

  # Gets the possible turns moving cards from the tableaus
  def get_tableau_turns
    turns = []

    @tableaus.each_index do |tableau_index|
      get_turns_for_single_tableau(tableau_index, turns)
    end

    turns
  end

  # Gets the possible turns moving cards from the foundations
  def get_foundation_turns
    turns = []

    [@diamonds_foundation, @spades_foundation, @hearts_foundation,
        @clubs_foundation].each do |foundation|
      bottom_card = foundation.bottom
      next if bottom_card.nil?

      stack = StackOfCards.new [foundation.bottom]
      indices = get_tableaus_stack_can_be_appended_to(stack)

      indices.each { |index|
        turns << FoundationToTableauTurn.new(self, foundation.suit, index)
      }
    end

    turns
  end

  # Gets the possible turns involving the stock
  def get_stock_turns
    if !(@stock.empty? && @waste.empty?)
      [FlipStockTurn.new(self)]
    else
      []
    end
  end

  # Moves the bottom card on the tableau to the foundation for its suit.
  # Raises an error if the move cannot be completed.
  # This version of the method modifies the current board instead of creating a
  # new board.
  def move_from_tableau_to_foundation!(from_tableau_index)
    do_move do
      from_tableau = get_tableau_for_move(from_tableau_index)

      new_from_tableau, bottom_card = from_tableau.remove_card

      raise "Tableau at #{from_tableau_index} is empty" if bottom_card.nil?

      suit = bottom_card.suit

      foundation = get_foundation_for_move(suit)

      new_foundation = foundation.append_card bottom_card

      set_tableau_after_move(from_tableau_index, new_from_tableau)
      set_foundation_after_move(suit, new_foundation)
    end
  end

  # Moves cards from one tableau to another.
  def move_between_tableaus!(from_tableau_index, to_tableau_index, num_to_move)
    do_move do
      from_tableau = get_tableau_for_move(from_tableau_index)
      to_tableau = get_tableau_for_move(to_tableau_index)

      new_from_tableau, stack = from_tableau.remove_stack num_to_move
      new_to_tableau = to_tableau.append_stack stack

      set_tableau_after_move(from_tableau_index, new_from_tableau)
      set_tableau_after_move(to_tableau_index, new_to_tableau)
    end
  end

  # Moves the top card on the waste pile to one of the tableaus
  def move_top_waste_card_to_tableau!(to_tableau_index)
    do_move do
      new_waste, card = @waste.remove_card

      raise "No waste card to move" if card.nil?

      to_tableau = get_tableau_for_move(to_tableau_index)

      new_to_tableau = to_tableau.append_card card

      @waste = new_waste
      set_tableau_after_move(to_tableau_index, new_to_tableau)
    end
  end

  # Moves the top waste card to the foundation for its suit
  def move_top_waste_card_to_foundation!
    do_move do
      new_waste, card = @waste.remove_card

      raise "No waste card to move" if card.nil?

      suit = card.suit

      foundation = get_foundation_for_move(suit)

      new_foundation = foundation.append_card card

      @waste = new_waste
      set_foundation_after_move(suit, new_foundation)
    end
  end

  # Moves the top card from a foundation to a tableau
  def move_from_foundation_to_tableau!(suit, to_tableau_index)
    do_move do
      foundation = get_foundation_for_move(suit)
      to_tableau = get_tableau_for_move(to_tableau_index)

      new_foundation, card = foundation.remove_card

      raise "No card on foundation to move" if card.nil?

      new_to_tableau = to_tableau.append_card card

      set_foundation_after_move(suit, foundation)
      set_tableau_after_move(to_tableau_index, new_to_tableau)
    end
  end

  # Flips the next stock card over.  If no more cards are left in the stock
  # pile then the waste pile is flipped back over into the stock pile.
  def flip_next_stock_card!
    do_move do
      if @stock.size == 0
        if @waste.size == 0 
          raise "No waste or stock cards left"
        end

        @stock = StackOfCards.new @waste.to_a.reverse
        @waste = StackOfCards.new []
      else
        @next_waste_card = @stock.remove_card!
      end
    end
  end

  # Finalizes the board's state after a move, flipping any hidden cards that
  # should now be visible.  Nothing is done if the board does not have a move
  # to finalize.
  def finalize_move!
    return unless @moving
    unless @next_waste_card.nil?
      @waste.append_card! @next_waste_card
      @next_waste_card = nil
    end
    @tableaus.each { |tableau| tableau.update_from_hidden_if_empty!  }
    @moving = false
  end

# ------------------------------------------------------------------------------
# :section: Object overrides
# The following methods are overrides for built-in Object methods.  These
# overrides are to allow for proper equality checking, duplication, etc.
# ------------------------------------------------------------------------------

  def dup
    SolitaireBoard.new to_state_hash
  end

  # Checks if this board is equal to another objects.  This ignores the turn
  # count.
  def eql?(board)
    check_equal(board, [
        :@diamonds_foundation,
        :@clubs_foundation,
        :@spades_foundation,
        :@hearts_foundation,
        :@stock,
        :@waste,
        :@tableaus
    ])
  end

  def ==(board)
    eql? board
  end

  def hash
    generate_hash([
        :@diamonds_foundation,
        :@clubs_foundation,
        :@spades_foundation,
        :@hearts_foundation,
        :@stock,
        :@waste,
        :@tableaus
    ])
  end

  def to_s
    "Solitaire Board: #{hash}"
  end

# ------------------------------------------------------------------------------
# :section: Private functions
# ------------------------------------------------------------------------------
private
  # Copies this board's full state into a hash table suitable for passing to
  # SolitaireBoard.new
  def to_state_hash
    {
      :diamonds_foundation => @diamonds_foundation.dup,
      :clubs_foundation => @clubs_foundation.dup,
      :spades_foundation => @spades_foundation.dup,
      :hearts_foundation => @hearts_foundation.dup,
      :tableaus => @tableaus.map { |tableau| tableau.dup },
      :stock => @stock.dup,
      :waste => @waste.dup,
      :turn_count => @turn_count
    }
  end

  # Gets a state value from the state hash.  If no value with the given ID is
  # found (returns nil) and a block was provided then the block will be run and
  # its return value used.
  def get_state(state, id, &block)
    s = state[id] unless state.nil?
    return s unless s.nil?

    yield block unless block.nil?
  end

  # Gets a tableau.  This method is to be used when getting a tableau for
  # applying a move.  If the tableau doesn't exist then an InvalidMoveError is
  # raised.
  def get_tableau_for_move(index)
    tableau = @tableaus[index]

    if tableau.nil?
      raise InvalidMoveError, "No tableau at index #{tableau_index}"
    end

    tableau
  end

  # Sets a tableau after a move was completed.
  def set_tableau_after_move(index, tableau)
    @tableaus[index] = tableau
  end

  # Gets the foundation for the given suit.
  # This method is to be used for getting the foundation while applying a move.
  # If the foundation doesn't exist (bad suit) then an InvalidMoveError will be
  # raised.
  def get_foundation_for_move(suit)
    case suit
    when :diamonds
      @diamonds_foundation
    when :spades
      @spades_foundation
    when :clubs
      @clubs_foundation
    when :hearts
      @hearts_foundation
    else
      raise InvalidMoveError, "Invalid suit: #{suit}"
    end
  end

  # Sets the foundation for the given suit.
  def set_foundation_after_move(suit, foundation)
    case suit
    when :diamonds
      @diamonds_foundation = foundation
    when :spades
      @spades_foundation = foundation
    when :clubs
      @clubs_foundation = foundation
    when :hearts
      @hearts_foundation = foundation
    else
      raise "Invalid suit: #{suit}"
    end
  end

  # Helper method for doing a move.  Takes a block for the move logic and runs
  # it.  Any exceptions raised by the block will result in an InvalidMoveError
  # being rasied.
  # This also handles starting the move and incrementing the turn count.
  def do_move(&block)
    raise InvalidMoveError, "Already doing a move" if @moving
    @moving = true

    begin
      yield block
    rescue RuntimeError => e
      @moving = false
      raise InvalidMoveError, "Unable to do move: #{e.message}"
    end
    @turn_count += 1
  end

  # Gets all turns possible from a single tableau and adds them to the passed
  # in turns array
  def get_turns_for_single_tableau(tableau_index, turns=nil)
    turns = [] if turns.nil?

    tableau = get_tableau_for_move tableau_index

    1.upto(tableau.size) do |size|
      new_tableau, stack = tableau.remove_stack(size)

      appendable_indices = get_tableaus_stack_can_be_appended_to(stack)

      appendable_indices.each do |index|
        next if index == tableau_index
        turns << TableauToTableauTurn.new(self, tableau_index, index, size)
      end
    end

    bottom_card = tableau.bottom
    return turns if bottom_card.nil?

    foundation = get_foundation_for_move(bottom_card.suit)
    if foundation.can_append_card?(bottom_card)
      turns << TableauToFoundationTurn.new(self, tableau_index)
    end

    turns
  end

  # Gets the indices of all tableaus the given stack can be appended to.
  def get_tableaus_stack_can_be_appended_to(stack)
    indices = []

    @tableaus.each_index do |tableau_index|
      tableau = @tableaus[tableau_index]

      if tableau.can_append?(stack)
        indices << tableau_index
      end
    end

    indices
  end
end
