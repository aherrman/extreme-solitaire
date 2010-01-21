$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'tableau'

class TableauTest < Test::Unit::TestCase
  def test_bottom_card_in_init_array_is_only_visible_card
    c1 = Card.get 10, :hearts
    c2 = Card.get 4, :hearts
    c3 = Card.get 7, :clubs

    column = Tableau.new [c1, c2, c3]

    assert_equal 1, column.size
    assert_equal c3, column[0]
  end

  def test_num_hidden_cards_is_one_less_than_initial_cards_array
    c1 = Card.get 10, :hearts
    c2 = Card.get 4, :hearts
    c3 = Card.get 7, :clubs

    column = Tableau.new [c1, c2, c3]

    assert_equal 2, column.num_hidden
  end

  def test_hidden_card_not_used_when_cards_are_left
    c1 = Card.get 10, :hearts
    c2 = Card.get 4, :hearts
    c3 = Card.get 7, :clubs
    c4 = Card.get 6, :diamonds

    column = Tableau.new [c1, c2], [c3, c4]
    new_column, card = column.remove_card

    new_column.update_from_hidden_if_empty!

    assert_equal 1, new_column.size
    assert_equal c3, new_column[0]
    assert_equal 2, new_column.num_hidden
  end

  def test_hidden_card_used_when_last_card_removed
    c1 = Card.get 10, :hearts
    c2 = Card.get 4, :hearts
    c3 = Card.get 7, :clubs

    column = Tableau.new [c1, c2, c3]
    new_column, card = column.remove_card

    new_column.update_from_hidden_if_empty!

    assert_equal 1, new_column.size
    assert_equal c2, new_column[0]
  end

  def test_hidden_card_used_when_all_cards_removed
    c1 = Card.get 10, :hearts
    c2 = Card.get 4, :hearts
    c3 = Card.get 7, :clubs

    column = Tableau.new [c1, c2, c3]
    new_column, stack = column.remove_stack(1)

    new_column.update_from_hidden_if_empty!

    assert_equal 1, new_column.size
    assert_equal c2, new_column[0]
  end

  def test_can_append_king_when_empty
    column = Tableau.new []

    assert column.can_append_card?(Card.get(Card::KING, :clubs))
  end

  def test_can_append_king_stack_when_empty
    c1 = Card.get(Card::KING, :clubs)
    c2 = Card.get(Card::QUEEN, :diamonds)

    column = Tableau.new []
    king_stack = StackOfCards.new [c1, c2]

    assert column.can_append?(king_stack)
  end

  def test_cannot_append_non_king_when_empty
    column = Tableau.new []

    assert ! column.can_append_card?(Card.get(9, :clubs))
  end

  def test_cannot_append_non_king_stack_when_empty
    c1 = Card.get(9, :clubs)
    c2 = Card.get(8, :diamonds)

    column = Tableau.new []
    non_king_stack = StackOfCards.new [c1, c2]

    assert ! column.can_append?(non_king_stack)
  end

  def test_equal_when_hidden_cards_are_equal
    c1 = Card.get 10, :hearts
    c2 = Card.get 4, :hearts
    c3 = Card.get 7, :clubs

    column1 = Tableau.new [c1, c2, c3]
    column2 = Tableau.new [c1, c2, c3]

    assert_equal column1, column2
  end

  def test_not_equal_when_hidden_cards_are_not_equal
    c1 = Card.get 10, :hearts
    c2 = Card.get 4, :hearts
    c3 = Card.get 7, :clubs

    column1 = Tableau.new [c1, c2, c3]
    column2 = Tableau.new [c2, c1, c3]

    assert_not_equal column1, column2
  end

  def test_card_display_displays_hidden_for_hidden_index
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    d = Tableau.new [c1, c2, c3]

    assert_equal "[###]", d.card_display(1)
  end

  def test_card_display_displays_normal_after_hidden
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    d = Tableau.new [c1, c2, c3]

    assert_equal "[3 C]", d.card_display(2)
  end
end
