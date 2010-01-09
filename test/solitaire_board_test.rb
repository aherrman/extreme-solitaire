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

end
