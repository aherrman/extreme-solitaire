$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'solitaire_board'
require 'turn/tableau_to_foundation_turn'
require 'turn/tableau_to_tableau_turn'
require 'turn/waste_to_tableau_turn'
require 'turn/waste_to_foundation_turn'
require 'turn/foundation_to_tableau_turn'
require 'turn/flip_stock_turn'

class TurnsTest < Test::Unit::TestCase

  def test_try_turn_does_not_finalize
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

    turn = TableauToFoundationTurn.new(board, 1)

    board2 = turn.try_turn

    assert board2.moving
  end

  def test_do_turn_finalizes
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

    turn = TableauToFoundationTurn.new(board, 1)

    board2 = turn.do_turn

    assert ! board2.moving
  end

  def test_do_turn_returns_new_board
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

    turn = TableauToFoundationTurn.new(board, 1)

    board2 = turn.do_turn
    board3 = turn.do_turn

    assert ! board.equal?(board2)
    assert ! board2.equal?(board3)
  end

  def test_tableau_to_foundation_turn
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

    turn = TableauToFoundationTurn.new(board, 1)

    board2 = turn.do_turn

    assert_equal d3, board2.diamonds_foundation_top
  end

  def test_tableau_to_tableau_turn
    h4 = Card.get(4, :hearts)
    c3 = Card.get(3, :clubs)
    d2 = Card.get(2, :diamonds)
    c7 = Card.get(7, :clubs)
    tableau1 = Tableau.new [h4]
    tableau2 = Tableau.new [c7, c3]
    tableau2.append_card! d2

    tableaus = [tableau1, tableau2]

    state = {
      :tableaus => tableaus,
    }

    board = SolitaireBoard.new state

    turn = TableauToTableauTurn.new board, 1, 0, 2

    board2 = turn.do_turn

    t1_cards = board2.get_tableau_cards(0)

    assert_equal h4, board2.get_tableau_cards(0)[0]
    assert_equal c3, board2.get_tableau_cards(0)[1]
    assert_equal 3, board2.get_tableau_cards(0).size

    assert_equal c7, board2.get_tableau_cards(1)[0]
    assert_equal 1, board2.get_tableau_cards(1).size
    assert_equal 0, board2.get_num_hidden_cards_for_tableau(1)
  end

  def test_waste_to_tableau_turn
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

    turn = WasteToTableauTurn.new(board, 1)

    board2 = turn.do_turn

    assert_equal 2, board2.get_tableau_cards(1).size
    assert_equal d7, board2.get_tableau_cards(1)[0]
    assert_equal c6, board2.get_tableau_cards(1)[1]
  end

  def test_waste_to_foundation_turn
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

    turn = WasteToFoundationTurn.new board

    board2 = turn.do_turn

    assert_equal d3, board2.diamonds_foundation_top
  end

  def test_foundation_to_tableau_turn
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

    turn = FoundationToTableauTurn.new board, :diamonds, 1
    board2 = turn.do_turn

    assert_equal 2, board2.get_tableau_cards(1).size
    assert_equal s4, board2.get_tableau_cards(1)[0]
    assert_equal d3, board2.get_tableau_cards(1)[1]
  end

  def test_flip_stock_turn
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

    turn = FlipStockTurn.new board
    board2 = turn.do_turn

    assert_equal d3, board2.top_waste_card
    assert_equal 2, board2.num_waste_cards
    assert_equal 1, board2.num_stock_cards
  end
  
end
