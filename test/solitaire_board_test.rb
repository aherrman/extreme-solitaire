$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'solitaire_board'

class SolitaireBoardTest < Test::Unit::TestCase

  def test_can_construct_from_full_state
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    s1 = Card.get Card::ACE, :spades
    s2 = Card.get 2, :spades
    s3 = Card.get 3, :spades

    c1 = Card.get Card::ACE, :clubs
    c2 = Card.get 2, :clubs
    c3 = Card.get 3, :clubs

    h1 = Card.get Card::ACE, :hearts
    h2 = Card.get 2, :hearts
    h3 = Card.get 3, :hearts

    diamonds_foundation = Foundation.new [d1, d2, d3], :diamonds
    spades_foundation = Foundation.new [s1, s2, s3], :spades
    clubs_foundation = Foundation.new [c1, c2, c3], :clubs
    hearts_foundation = Foundation.new [h1, h2, h3], :hearts

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), Card.get(9, :diamonds)]

    tableaus = [tableau1, tableau2]

    unused = StackOfCards.new [Card.get(6, :clubs)]
    used = StackOfCards.new [Card.get(6, :clubs)]
    turns = 30

    state = {
      :diamonds_foundation => diamonds_foundation,
      :clubs_foundation => clubs_foundation,
      :spades_foundation => spades_foundation,
      :hearts_foundation => hearts_foundation,
      :tableaus => tableaus,
      :stock => unused,
      :waste => used,
      :turn_count => turns
    }

    board = SolitaireBoard.new state

    empty_tableau = StackOfCards.new []

    assert_equal d3, board.diamonds_foundation_top
    assert_equal h3, board.hearts_foundation_top
    assert_equal c3, board.clubs_foundation_top
    assert_equal s3, board.spades_foundation_top

    assert_equal StackOfCards.new(tableau1), board.get_tableau_cards(0)
    assert_equal StackOfCards.new(tableau2), board.get_tableau_cards(1)
    assert_equal empty_tableau, board.get_tableau_cards(2)
    assert_equal empty_tableau, board.get_tableau_cards(3)
    assert_equal empty_tableau, board.get_tableau_cards(4)
    assert_equal empty_tableau, board.get_tableau_cards(5)
    assert_equal empty_tableau, board.get_tableau_cards(6)

    assert_equal used[0], board.top_waste_card
    assert_equal used.size, board.num_waste_cards
    assert_equal unused.size, board.num_stock_cards
    assert_equal turns, board.turn_count
  end

  def test_can_build_from_deck
    deck = StackOfCards.default_stack

    board = SolitaireBoard.build_from_deck deck

    assert board.diamonds_foundation_top.nil?
    assert board.hearts_foundation_top.nil?
    assert board.clubs_foundation_top.nil?
    assert board.spades_foundation_top.nil?

    t0 = board.get_tableau_cards(0)
    assert_equal Card.get(13, :diamonds), t0[0]
    assert_equal 0, board.get_num_hidden_cards_for_tableau(0)

    t1 = board.get_tableau_cards(1)
    assert_equal Card.get(6, :diamonds), t1[0]
    assert_equal 1, board.get_num_hidden_cards_for_tableau(1)

    t2 = board.get_tableau_cards(2)
    assert_equal Card.get(13, :clubs), t2[0]
    assert_equal 2, board.get_num_hidden_cards_for_tableau(2)

    t3 = board.get_tableau_cards(3)
    assert_equal Card.get(8, :clubs), t3[0]
    assert_equal 3, board.get_num_hidden_cards_for_tableau(3)

    t4 = board.get_tableau_cards(4)
    assert_equal Card.get(4, :clubs), t4[0]
    assert_equal 4, board.get_num_hidden_cards_for_tableau(4)

    t5 = board.get_tableau_cards(5)
    assert_equal Card.get(1, :clubs), t5[0]
    assert_equal 5, board.get_num_hidden_cards_for_tableau(5)

    t6 = board.get_tableau_cards(6)
    assert_equal Card.get(12, :spades), t6[0]
    assert_equal 6, board.get_num_hidden_cards_for_tableau(6)

    assert_equal 0, board.turn_count

    assert_equal 0, board.num_waste_cards
    assert_equal 24, board.num_stock_cards
  end

  def test_equal
    board1 = SolitaireBoard.build_from_deck StackOfCards.default_stack
    board2 = SolitaireBoard.build_from_deck StackOfCards.default_stack

    assert_equal board1, board2
  end

  def test_empty_boards_are_equal
    board1 = SolitaireBoard.new
    board2 = SolitaireBoard.new

    assert_equal board1, board2
  end

  def test_dup
    board1 = SolitaireBoard.build_from_deck StackOfCards.default_stack
    board2 = board1.dup

    assert ! board1.equal?(board2)
    assert_equal board1, board2
  end

  def test_not_equal_when_diamonds_foundation_is_different
    c1 = Card.get Card::ACE, :diamonds
    c2 = Card.get 2, :diamonds
    c3 = Card.get 3, :diamonds

    state1 = { :diamonds_foundation => Foundation.new([c1, c2], :diamonds)}
    state2 = { :diamonds_foundation => Foundation.new([c1, c2, c3], :diamonds)}

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2

    assert_not_equal board1, board2
  end

  def test_not_equal_when_clubs_foundation_is_different
    c1 = Card.get Card::ACE, :clubs
    c2 = Card.get 2, :clubs
    c3 = Card.get 3, :clubs

    state1 = { :clubs_foundation => Foundation.new([c1, c2], :clubs)}
    state2 = { :clubs_foundation => Foundation.new([c1, c2, c3], :clubs)}

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2

    assert_not_equal board1, board2
  end

  def test_not_equal_when_hearts_foundation_is_different
    c1 = Card.get Card::ACE, :hearts
    c2 = Card.get 2, :hearts
    c3 = Card.get 3, :hearts

    state1 = { :hearts_foundation => Foundation.new([c1, c2], :hearts)}
    state2 = { :hearts_foundation => Foundation.new([c1, c2, c3], :hearts)}

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2

    assert_not_equal board1, board2
  end

  def test_not_equal_when_spades_foundation_is_different
    c1 = Card.get Card::ACE, :spades
    c2 = Card.get 2, :spades
    c3 = Card.get 3, :spades

    state1 = { :spades_foundation => Foundation.new([c1, c2], :spades)}
    state2 = { :spades_foundation => Foundation.new([c1, c2, c3], :spades)}

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2

    assert_not_equal board1, board2
  end

  def test_not_equal_when_tableaus_are_different
    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), Card.get(9, :diamonds)]
    tableau3 = Tableau.new [Card.get(4, :clubs), Card.get(2, :spades)]

    tableaus1 = [tableau1, tableau2]
    tableaus2 = [tableau1, tableau2, tableau3]
    tableaus3 = [tableau1, tableau3]

    state1 = { :tableaus => tableaus1 }
    state2 = { :tableaus => tableaus2 }
    state3 = { :tableaus => tableaus3 }

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2
    board3 = SolitaireBoard.new state3

    assert_not_equal board1, board2
    assert_not_equal board1, board3
  end

  def test_not_equal_when_stock_is_different
    c1 = Card.get Card::ACE, :spades
    c2 = Card.get 2, :spades
    c3 = Card.get 3, :spades

    state1 = { :stock => StackOfCards.new([c1, c2]) }
    state2 = { :stock => StackOfCards.new([c1, c2, c3]) }

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2

    assert_not_equal board1, board2
  end

  def test_not_equal_when_waste_is_different
    c1 = Card.get Card::ACE, :spades
    c2 = Card.get 2, :spades
    c3 = Card.get 3, :spades

    state1 = { :waste => StackOfCards.new([c1, c2]) }
    state2 = { :waste => StackOfCards.new([c1, c2, c3]) }

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2

    assert_not_equal board1, board2
  end

  def test_equal_when_only_turn_count_is_different
    state1 = { :turn_count => 1 }
    state2 = { :turn_count => 2 }

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2

    assert_equal board1, board2
  end

  def test_eql_ignores_turn_count
    state1 = { :turn_count => 1 }
    state2 = { :turn_count => 2 }

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2

    assert_equal board1, board2
  end

  def test_eql_including_turn_count
    state1 = { :turn_count => 1 }
    state2 = { :turn_count => 1 }

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2

    assert board1.eql_including_turn_count?(board2)
  end

  def test_eql_including_turn_count_checks_turn_count
    state1 = { :turn_count => 1 }
    state2 = { :turn_count => 2 }

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2

    assert ! board1.eql_including_turn_count?(board2)
  end

  def test_same_boards_have_same_hash
    deck = StackOfCards.default_stack

    board1 = SolitaireBoard.build_from_deck deck
    board2 = SolitaireBoard.build_from_deck deck

    assert_equal board1.hash, board2.hash
  end

  def test_different_boards_have_different_hash
    deck = StackOfCards.default_stack

    board1 = SolitaireBoard.build_from_deck deck.shuffle
    board2 = SolitaireBoard.build_from_deck deck.shuffle

    assert_not_equal board1.hash, board2.hash
  end

  def test_hash_ignores_turn_count
    state1 = { :turn_count => 1 }
    state2 = { :turn_count => 2 }

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2

    assert_equal board1.hash, board2.hash
  end

  def test_move_from_tableau_to_foundation
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    diamonds_foundation = Foundation.new [d1, d2], :diamonds

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), d3]

    tableaus = [tableau1, tableau2]

    state = {
      :diamonds_foundation => diamonds_foundation,
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    board.move_from_tableau_to_foundation!(1)

    assert_equal d3, board.diamonds_foundation_top
  end

  def test_move_from_tableau_to_foundation_throws_error_on_invalid_move
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    diamonds_foundation = Foundation.new [d1, d2], :diamonds

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), d3]

    tableaus = [tableau1, tableau2]

    state = {
      :diamonds_foundation => diamonds_foundation,
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    assert_raise(InvalidMoveError) {
      board.move_from_tableau_to_foundation!(0)
    }
  end

  def test_move_increments_turn_count
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    diamonds_foundation = Foundation.new [d1, d2], :diamonds

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), d3]

    tableaus = [tableau1, tableau2]

    state = {
      :diamonds_foundation => diamonds_foundation,
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    board.move_from_tableau_to_foundation!(1)

    assert_equal 1, board.turn_count
  end

  def test_cannot_move_when_move_is_in_progress
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    diamonds_foundation = Foundation.new [d1, d2], :diamonds

    tableau1 = Tableau.new [Card.get(4, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), d3]

    tableaus = [tableau1, tableau2]

    state = {
      :diamonds_foundation => diamonds_foundation,
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    board.move_from_tableau_to_foundation!(1)

    assert_raise(InvalidMoveError) {
      board.move_from_tableau_to_foundation!(0)
    }
  end

  def test_move_between_tableaus
    h4 = Card.get(4, :hearts)
    c3 = Card.get(3, :clubs)
    d2 = Card.get(2, :diamonds)
    c7 = Card.get(7, :clubs)
    tableau1 = Tableau.new [h4]
    tableau2 = Tableau.new [c7], [c3, d2]

    tableaus = [tableau1, tableau2]

    state = {
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    board.move_between_tableaus!(1, 0, 2)

    t1_cards = board.get_tableau_cards(0)
    board.finalize_move!

    assert_equal h4, board.get_tableau_cards(0)[0]
    assert_equal c3, board.get_tableau_cards(0)[1]
    assert_equal 3, board.get_tableau_cards(0).size

    assert_equal c7, board.get_tableau_cards(1)[0]
    assert_equal 1, board.get_tableau_cards(1).size
    assert_equal 0, board.get_num_hidden_cards_for_tableau(1)
  end

  def test_move_between_tableaus_throws_error_on_invalid_move
    h4 = Card.get(4, :hearts)
    c3 = Card.get(3, :clubs)
    c7 = Card.get(7, :clubs)
    tableau1 = Tableau.new [h4]
    tableau2 = Tableau.new [c7, c3]

    tableaus = [tableau1, tableau2]

    state = {
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    assert_raise(InvalidMoveError) {
      board.move_between_tableaus!(0, 1, 1)
    }
  end

  def test_move_top_waste_card_to_tableau
    d7 = Card.get 7, :diamonds
    c6 = Card.get 6, :clubs

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), d7]

    tableaus = [tableau1, tableau2]

    used = StackOfCards.new [Card.get(10, :hearts), c6]

    state = {
      :tableaus => tableaus,
      :waste => used,
    }

    board = SolitaireBoard.new state

    board.move_top_waste_card_to_tableau! 1

    assert_equal 2, board.get_tableau_cards(1).size
    assert_equal d7, board.get_tableau_cards(1)[0]
    assert_equal c6, board.get_tableau_cards(1)[1]
  end

  def test_move_top_waste_card_to_tableau_fails_when_no_waste_card
    d7 = Card.get 7, :diamonds
    c6 = Card.get 6, :clubs

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), d7]

    tableaus = [tableau1, tableau2]

    state = {
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    assert_raise(InvalidMoveError) {
      board.move_top_waste_card_to_tableau! 1
    }
  end

  def test_move_top_waste_card_to_tableau_fails_when_invalid_move
    d7 = Card.get 7, :diamonds
    h6 = Card.get 6, :hearts

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), d7]

    tableaus = [tableau1, tableau2]

    waste = StackOfCards.new [Card.get(10, :hearts), h6]

    state = {
      :tableaus => tableaus,
      :waste => waste,
    }

    board = SolitaireBoard.new state

    assert_raise(InvalidMoveError) {
      board.move_top_waste_card_to_tableau! 1
    }
  end

  def test_move_top_waste_card_to_foundation
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    diamonds_foundation = Foundation.new [d1, d2], :diamonds
    waste = StackOfCards.new [Card.get(10, :hearts), d3]

    state = {
      :diamonds_foundation => diamonds_foundation,
      :waste => waste,
    }

    board = SolitaireBoard.new state

    board.move_top_waste_card_to_foundation!

    assert_equal d3, board.diamonds_foundation_top
  end

  def test_move_top_waste_card_to_foundation_fails_on_invalid_move
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d4 = Card.get 4, :diamonds

    diamonds_foundation = Foundation.new [d1, d2], :diamonds
    waste = StackOfCards.new [Card.get(10, :hearts), d4]

    state = {
      :diamonds_foundation => diamonds_foundation,
      :waste => waste,
    }

    board = SolitaireBoard.new state

    assert_raise(InvalidMoveError) {
      board.move_top_waste_card_to_foundation!
    }
  end

  def test_move_top_waste_card_to_foundation_fails_when_no_waste
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds

    diamonds_foundation = Foundation.new [d1, d2], :diamonds

    state = {
      :diamonds_foundation => diamonds_foundation,
    }

    board = SolitaireBoard.new state

    assert_raise(InvalidMoveError) {
      board.move_top_waste_card_to_foundation!
    }
  end

  def test_move_from_foundation_to_tableau
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds
    s4 = Card.get 4, :spades

    diamonds_foundation = Foundation.new [d1, d2, d3], :diamonds

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), s4]

    tableaus = [tableau1, tableau2]

    state = {
      :diamonds_foundation => diamonds_foundation,
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    board.move_from_foundation_to_tableau!(:diamonds, 1)

    assert_equal 2, board.get_tableau_cards(1).size
    assert_equal s4, board.get_tableau_cards(1)[0]
    assert_equal d3, board.get_tableau_cards(1)[1]
  end

  def test_move_from_foundation_to_tableau_fails_on_invalid_move
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    diamonds_foundation = Foundation.new [d1, d2, d3], :diamonds

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), Card.get(5, :spades)]

    tableaus = [tableau1, tableau2]

    state = {
      :diamonds_foundation => diamonds_foundation,
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    assert_raise(InvalidMoveError) {
      board.move_from_foundation_to_tableau!(:diamonds, 1)
    }
  end

  def test_flip_next_stock_card_when_cards_available
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    stock = StackOfCards.new [d2, d3]
    waste = StackOfCards.new [d1]

    state = {
      :stock => stock,
      :waste => waste,
    }

    board = SolitaireBoard.new state

    board.flip_next_stock_card!
    board.finalize_move!

    assert_equal d3, board.top_waste_card
    assert_equal 2, board.num_waste_cards
    assert_equal 1, board.num_stock_cards
  end

  def test_flip_next_stock_card_doesnt_show_card_until_finalized
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    stock = StackOfCards.new [d2, d3]
    waste = StackOfCards.new [d1]

    state = {
      :stock => stock,
      :waste => waste,
    }

    board = SolitaireBoard.new state

    board.flip_next_stock_card!

    assert_equal d1, board.top_waste_card
    assert_equal 1, board.num_waste_cards
    assert_equal 1, board.num_stock_cards
  end

  def test_flip_next_stock_card_resets_stock_when_empty
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    stock = StackOfCards.new []
    waste = StackOfCards.new [d1, d2, d3]

    state = {
      :stock => stock,
      :waste => waste,
    }

    board = SolitaireBoard.new state

    board.flip_next_stock_card!

    assert board.top_waste_card.nil?
    assert_equal 3, board.num_stock_cards
  end

  def test_flip_next_stock_card_preserves_correct_order_on_reset
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    stock = StackOfCards.new []
    waste = StackOfCards.new [d1, d2, d3]

    state = {
      :stock => stock,
      :waste => waste,
    }

    board = SolitaireBoard.new state

    board.flip_next_stock_card!
    board.finalize_move!

    assert board.top_waste_card.nil?

    board.flip_next_stock_card!
    board.finalize_move!
    assert_equal d1, board.top_waste_card

    board.flip_next_stock_card!
    board.finalize_move!
    assert_equal d2, board.top_waste_card

    board.flip_next_stock_card!
    board.finalize_move!
    assert_equal d3, board.top_waste_card
  end

  def test_finalize_flips_hidden_cards
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds
    c7 = Card.get 7, :clubs

    diamonds_foundation = Foundation.new [d1, d2], :diamonds

    tableau1 = Tableau.new [Card.get(4, :hearts)]
    tableau2 = Tableau.new [c7, d3]

    tableaus = [tableau1, tableau2]

    state = {
      :diamonds_foundation => diamonds_foundation,
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    board.move_from_tableau_to_foundation!(1)

    assert board.get_tableau_cards(1).bottom.nil?

    board.finalize_move!

    assert_equal c7, board.get_tableau_cards(1).bottom
  end

  def test_get_waste_turns_for_waste_to_tableau
    d7 = Card.get 7, :diamonds
    c6 = Card.get 6, :clubs

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), d7]

    tableaus = [tableau1, tableau2]

    used = StackOfCards.new [Card.get(10, :hearts), c6]

    state = {
      :tableaus => tableaus,
      :waste => used,
    }

    board = SolitaireBoard.new state

    turns = board.get_waste_turns

    assert_equal 1, turns.size
    assert turns[0].is_a?(WasteToTableauTurn)
    assert_equal 1, turns[0].to_tableau_index
  end

  def test_get_waste_turns_for_waste_to_foundation
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    diamonds_foundation = Foundation.new [d1, d2], :diamonds
    waste = StackOfCards.new [Card.get(10, :hearts), d3]

    state = {
      :diamonds_foundation => diamonds_foundation,
      :waste => waste,
    }

    board = SolitaireBoard.new state
    turns = board.get_waste_turns

    assert_equal 1, turns.size
    assert turns[0].is_a?(WasteToFoundationTurn)
  end

  def test_get_wate_turns_when_both_are_possible
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    diamonds_foundation = Foundation.new [d1, d2], :diamonds
    waste = StackOfCards.new [Card.get(10, :hearts), d3]

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(4, :clubs)]
    tableaus = [tableau1, tableau2]

    state = {
      :tableaus => tableaus,
      :diamonds_foundation => diamonds_foundation,
      :waste => waste,
    }

    board = SolitaireBoard.new state

    turns = board.get_waste_turns

    # Test shouldn't care about the order, but it's easier to do that for now.
    assert_equal 2, turns.size
    assert turns[0].is_a?(WasteToFoundationTurn)
    assert turns[1].is_a?(WasteToTableauTurn)
    assert_equal 1, turns[1].to_tableau_index
  end

  def test_get_tableau_turns_for_moves_between_tableaus
    h4 = Card.get(4, :hearts)
    c3 = Card.get(3, :clubs)
    d2 = Card.get(2, :diamonds)
    c7 = Card.get(7, :clubs)
    tableau1 = Tableau.new [h4]
    tableau2 = Tableau.new [c7], [c3, d2]

    tableau3 = Tableau.new [Card.get(7, :diamonds)]
    tableau4 = Tableau.new [Card.get(8, :spades)]

    tableaus = [tableau1, tableau2, tableau3, tableau4]

    state = {
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    turns = board.get_tableau_turns

    assert_equal 2, turns.size

    # Order shouldn't matter, but it's easier to test right now
    assert_equal 1, turns[0].from_tableau_index
    assert_equal 0, turns[0].to_tableau_index
    assert_equal 2, turns[0].num_to_move
    assert turns[0].is_a?(TableauToTableauTurn)

    assert_equal 2, turns[1].from_tableau_index
    assert_equal 3, turns[1].to_tableau_index
    assert_equal 1, turns[1].num_to_move
    assert turns[1].is_a?(TableauToTableauTurn)
  end

  def test_get_tableau_turns_for_moves_to_foundation
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    diamonds_foundation = Foundation.new [d1, d2], :diamonds

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), d3]

    tableaus = [tableau1, tableau2]

    state = {
      :diamonds_foundation => diamonds_foundation,
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    turns = board.get_tableau_turns

    assert_equal 1, turns.size
    assert turns[0].is_a?(TableauToFoundationTurn)
    assert_equal 1, turns[0].from_tableau_index
  end

  def test_get_foundation_turns
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds
    s4 = Card.get 4, :spades

    diamonds_foundation = Foundation.new [d1, d2, d3], :diamonds

    tableau1 = Tableau.new [Card.get(5, :hearts)]
    tableau2 = Tableau.new [Card.get(7, :clubs), s4]

    tableaus = [tableau1, tableau2]

    state = {
      :diamonds_foundation => diamonds_foundation,
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    turns = board.get_foundation_turns

    assert_equal 1, turns.size
    assert turns[0].is_a?(FoundationToTableauTurn)
    assert_equal :diamonds, turns[0].suit
    assert_equal 1, turns[0].to_tableau_index
  end

  def test_get_stock_turns
    d1 = Card.get Card::ACE, :diamonds
    d2 = Card.get 2, :diamonds
    d3 = Card.get 3, :diamonds

    stock = StackOfCards.new [d2, d3]
    waste = StackOfCards.new [d1]

    state = {
      :stock => stock,
      :waste => waste,
    }

    board = SolitaireBoard.new state

    turns = board.get_stock_turns

    assert_equal 1, turns.size
    assert turns[0].is_a?(FlipStockTurn)
  end

  def test_get_stock_turns_when_no_cards_left
    state = { }

    board = SolitaireBoard.new state

    turns = board.get_stock_turns

    assert_equal 0, turns.size
  end

  def test_get_turns_returns_empty_when_no_turns_avaialble
    h4 = Card.get(4, :hearts)
    tableau1 = Tableau.new [h4]

    tableaus = [tableau1]

    state = {
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    turns = board.get_tableau_turns

    assert turns.empty?
  end

  def test_get_waste_turns_only_allows_one_king_to_tableau_move
    diamonds = Foundation.build_foundation(13, :diamonds)

    t1 = Tableau.new [Card.get(2, :hearts)],
        [Card.get(13, :hearts), Card.get(12, :spades)]

    used = StackOfCards.new [Card.get(13, :clubs)]
    state = {
      :diamonds_foundation => diamonds,
      :waste => used,
      :tableaus => [t1]
    }

    board = SolitaireBoard.new state

    turns = board.get_waste_turns

    assert_equal 1, turns.size
    assert_equal WasteToTableauTurn, turns[0].class
  end

  def test_get_tableau_turns_only_allows_one_king_to_tableau_move
    diamonds = Foundation.build_foundation(13, :diamonds)

    t1 = Tableau.new [Card.get(2, :hearts)],
        [Card.get(13, :hearts), Card.get(12, :spades)]

    used = StackOfCards.new [Card.get(13, :clubs)]
    state = {
      :diamonds_foundation => diamonds,
      :waste => used,
      :tableaus => [t1]
    }

    board = SolitaireBoard.new state

    turns = board.get_tableau_turns

    assert_equal 1, turns.size
    assert_equal TableauToTableauTurn, turns[0].class
  end

  def test_get_foundation_turns_only_allows_one_king_to_tableau_move
    diamonds = Foundation.build_foundation(13, :diamonds)

    t1 = Tableau.new [Card.get(2, :hearts)],
        [Card.get(13, :hearts), Card.get(12, :spades)]

    used = StackOfCards.new [Card.get(13, :clubs)]
    state = {
      :diamonds_foundation => diamonds,
      :waste => used,
      :tableaus => [t1]
    }

    board = SolitaireBoard.new state

    turns = board.get_foundation_turns

    assert_equal 1, turns.size
    assert_equal FoundationToTableauTurn, turns[0].class
  end

  def test_get_tableau_turns_doesnt_move_kings_with_nothing_hidden_under_them
    diamonds = Foundation.build_foundation(13, :diamonds)

    t1 = Tableau.new [], [Card.get(13, :hearts), Card.get(12, :spades)]

    used = StackOfCards.new [Card.get(13, :clubs)]
    state = {
      :diamonds_foundation => diamonds,
      :waste => used,
      :tableaus => [t1]
    }

    board = SolitaireBoard.new state

    turns = board.get_tableau_turns

    assert_equal 0, turns.size
  end

  def test_num_hidden
    deck = StackOfCards.default_stack

    board = SolitaireBoard.build_from_deck deck

    assert_equal 21, board.num_hidden
  end

  def test_solved
    diamonds = Foundation.build_foundation(13, :diamonds)
    clubs = Foundation.build_foundation(13, :clubs)
    hearts = Foundation.build_foundation(13, :hearts)
    spades = Foundation.build_foundation(13, :spades)

    state = {
      :diamonds_foundation => diamonds,
      :spades_foundation => spades,
      :hearts_foundation => hearts,
      :clubs_foundation => clubs
    }

    board = SolitaireBoard.new state

    assert board.solved?
  end

  def test_solved_when_not_solved
    diamonds = Foundation.build_foundation(13, :diamonds)
    clubs = Foundation.build_foundation(13, :clubs)
    hearts = Foundation.build_foundation(13, :hearts)
    spades = Foundation.build_foundation(12, :spades)

    state = {
      :diamonds_foundation => diamonds,
      :spades_foundation => spades,
      :hearts_foundation => hearts,
      :clubs_foundation => clubs
    }

    board = SolitaireBoard.new state

    assert ! board.solved?
  end
end
