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
      :unused_waste => unused,
      :used_waste => used,
      :turn_count => turns
    }

    board = SolitaireBoard.new state

    empty_tableau = Tableau.new []

    assert_equal diamonds_foundation, board.diamonds_foundation
    assert_equal hearts_foundation, board.hearts_foundation
    assert_equal clubs_foundation, board.clubs_foundation
    assert_equal spades_foundation, board.spades_foundation

    assert_equal tableau1, board.get_tableau(0)
    assert_equal tableau2, board.get_tableau(1)
    assert_equal empty_tableau, board.get_tableau(2)
    assert_equal empty_tableau, board.get_tableau(3)
    assert_equal empty_tableau, board.get_tableau(4)
    assert_equal empty_tableau, board.get_tableau(5)
    assert_equal empty_tableau, board.get_tableau(6)

    assert_equal used[0], board.top_waste_card
    assert_equal used.size, board.num_used_waste_cards
    assert_equal unused.size, board.num_unused_waste_cards
    assert_equal turns, board.turn_count
  end

  def test_can_build_from_deck
    deck = StackOfCards.default_stack

    board = SolitaireBoard.build_from_deck deck

    assert_equal 0, board.diamonds_foundation.size
    assert_equal 0, board.hearts_foundation.size
    assert_equal 0, board.clubs_foundation.size
    assert_equal 0, board.spades_foundation.size

    t0 = board.get_tableau(0)
    assert_equal Card.get(13, :diamonds), t0[0]
    assert_equal 0, t0.num_hidden

    t1 = board.get_tableau(1)
    assert_equal Card.get(12, :diamonds), t1[0]
    assert_equal 1, t1.num_hidden

    t2 = board.get_tableau(2)
    assert_equal Card.get(10, :diamonds), t2[0]
    assert_equal 2, t2.num_hidden

    t3 = board.get_tableau(3)
    assert_equal Card.get(7, :diamonds), t3[0]
    assert_equal 3, t3.num_hidden

    t4 = board.get_tableau(4)
    assert_equal Card.get(3, :diamonds), t4[0]
    assert_equal 4, t4.num_hidden

    t5 = board.get_tableau(5)
    assert_equal Card.get(11, :clubs), t5[0]
    assert_equal 5, t5.num_hidden

    t6 = board.get_tableau(6)
    assert_equal Card.get(5, :clubs), t6[0]
    assert_equal 6, t6.num_hidden

    assert_equal 0, board.turn_count

    assert_equal 0, board.num_used_waste_cards
    assert_equal 24, board.num_unused_waste_cards
  end

  def test_all_returned_stacks_are_immutable
    deck = StackOfCards.default_stack

    board = SolitaireBoard.build_from_deck deck

    check_immutable { board.diamonds_foundation.remove_card! }
    check_immutable { board.hearts_foundation.remove_card! }
    check_immutable { board.clubs_foundation.remove_card! }
    check_immutable { board.spades_foundation.remove_card! }

    (0..6).each { |i|
      check_immutable { board.get_tableau(i).remove_card! }
    }
  end

  def check_immutable
    thrown = false
    begin
      yield
    rescue RuntimeError => e
      assert_equal "Mutable methods not allowed", e.message
      thrown = true
    end

    assert thrown
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

  def test_not_equal_when_unused_waste_is_different
    c1 = Card.get Card::ACE, :spades
    c2 = Card.get 2, :spades
    c3 = Card.get 3, :spades

    state1 = { :unused_waste => StackOfCards.new([c1, c2]) }
    state2 = { :unused_waste => StackOfCards.new([c1, c2, c3]) }

    board1 = SolitaireBoard.new state1
    board2 = SolitaireBoard.new state2

    assert_not_equal board1, board2
  end

  def test_not_equal_when_used_waste_is_different
    c1 = Card.get Card::ACE, :spades
    c2 = Card.get 2, :spades
    c3 = Card.get 3, :spades

    state1 = { :used_waste => StackOfCards.new([c1, c2]) }
    state2 = { :used_waste => StackOfCards.new([c1, c2, c3]) }

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
end
