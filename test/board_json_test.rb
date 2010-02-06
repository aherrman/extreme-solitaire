$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'board_json'

class BoardJsonTest < Test::Unit::TestCase
  def test_card_json
    card = Card.get 10, :spades

    card2 = JSON.parse JSON.generate card

    assert_equal card, card2
  end

  def test_stack_of_cards_json
    cards = [Card.get(10, :spades), Card.get(4, :diamonds), Card.get(1, :hearts)]

    stack = StackOfCards.new cards

    stack2 = JSON.parse JSON.generate stack

    assert_equal stack, stack2
  end

  def test_tableau_json
    hidden = [Card.get(10, :spades), Card.get(4, :diamonds), Card.get(1, :hearts)]
    visible = [Card.get(3, :diamonds), Card.get(2, :clubs)]

    tableau = Tableau.new hidden, visible

    tableau2 = JSON.parse JSON.generate tableau

    assert_equal tableau, tableau2
  end

  def test_foundation_json
    cards = [Card.get(1, :spades), Card.get(2, :spades), Card.get(3, :spades)]

    foundation = Foundation.new cards, :spades

    foundation2 = JSON.parse JSON.generate foundation

    assert_equal foundation, foundation2
  end

  def test_solitaire_board_json
    board = SolitaireBoard.build_from_deck StackOfCards.default_stack

    board2 = JSON.parse JSON.generate board

    assert_equal board, board2
  end
end
