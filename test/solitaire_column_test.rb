$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'solitaire_column'

class SolitaireColumnTest < Test::Unit::TestCase
  def test_bottom_card_in_init_array_is_only_visible_card
    c1 = Card.get 10, :hearts
    c2 = Card.get 4, :hearts
    c3 = Card.get 7, :clubs

    column = SolitaireColumn.new [c1, c2, c3]

    assert_equal 1, column.size
    assert_equal c3, column[0]
  end

  def test_num_hidden_cards_is_one_less_than_initial_cards_array
    c1 = Card.get 10, :hearts
    c2 = Card.get 4, :hearts
    c3 = Card.get 7, :clubs

    column = SolitaireColumn.new [c1, c2, c3]

    assert_equal 2, column.num_hidden
  end

  def test_hidden_card_used_when_last_card_removed
    c1 = Card.get 10, :hearts
    c2 = Card.get 4, :hearts
    c3 = Card.get 7, :clubs

    column = SolitaireColumn.new [c1, c2, c3]
    new_column, card = column.remove_card

    assert_equal 1, new_column.size
    assert_equal c2, new_column[0]
  end

  def test_hidden_card_used_when_all_cards_removed
    c1 = Card.get 10, :hearts
    c2 = Card.get 4, :hearts
    c3 = Card.get 7, :clubs

    column = SolitaireColumn.new [c1, c2, c3]
    new_column, stack = column.remove_stack(1)

    assert_equal 1, new_column.size
    assert_equal c2, new_column[0]
  end

  def test_can_append_king_when_empty
    column = SolitaireColumn.new []

    assert column.can_append_card?(Card.get(Card::KING, :clubs))
  end

  def test_can_append_king_stack_when_empty
    c1 = Card.get(Card::KING, :clubs)
    c2 = Card.get(Card::QUEEN, :diamonds)

    column = SolitaireColumn.new []
    king_stack = StackOfCards.new [c1, c2]

    assert column.can_append?(king_stack)
  end

  def test_cannot_append_non_king_when_empty
    column = SolitaireColumn.new []

    assert ! column.can_append_card?(Card.get(9, :clubs))
  end

  def test_cannot_append_non_king_stack_when_empty
    c1 = Card.get(9, :clubs)
    c2 = Card.get(8, :diamonds)

    column = SolitaireColumn.new []
    non_king_stack = StackOfCards.new [c1, c2]

    assert ! column.can_append?(non_king_stack)
  end
end
