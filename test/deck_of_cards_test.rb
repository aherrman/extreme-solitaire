# 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'deck_of_cards'
require 'enum_helpers'

class DeckOfCardsTest < Test::Unit::TestCase
  def test_size
    d = DeckOfCards.new [Card.new(1, :hearts), Card.new(2, :spades)]

    assert_equal 2, d.size
  end

  def test_card
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)

    d = DeckOfCards.new [c1, c2, c3]

    assert_equal c1, d.card(0)
    assert_equal c2, d.card(1)
    assert_equal c3, d.card(2)
  end

  def test_index_array_style_access
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)

    d = DeckOfCards.new [c1, c2, c3]
    
    c = d[1]
    
    assert_equal c, c2
  end

  def test_start_len_array_style_access
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3, c4, c5]

    rc1, rc2, rc3 = d1[1, 3]
    assert_equal rc1, c2
    assert_equal rc2, c3
    assert_equal rc3, c4
  end

  def test_range_array_style_access
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3, c4, c5]

    rc1, rc2 = d1[1..2]
    assert_equal rc1, c2
    assert_equal rc2, c3
  end

  def test_cannot_modify_using_array_syntax
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3, c4, c5]

    assert_raise(NoMethodError) {
      d1[2] = Card.new(2, :hearts)
    }
  end

  def test_modifying_arg_array_doesnt_change_deck
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)

    a = [c1, c2, c3]

    d = DeckOfCards.new a

    a[1] = Card.new 5, :diamonds

    assert_equal c1, d.card(0)
    assert_equal c2, d.card(1)
    assert_equal c3, d.card(2)
  end

  def test_is_standard_deck_when_standard
    d = DeckOfCards.new [Card.new(1, :hearts), Card.new(2, :spades)]

    assert d.is_standard_deck?
  end

  def test_is_standard_deck_when_not_standard
    d = DeckOfCards.new [Card.new(1, :hearts), Card.new(2, :spades),
        Card.new(1, :hearts)]

    assert !d.is_standard_deck?
  end

  def test_dup
    d1 = DeckOfCards.new [Card.new(1, :hearts), Card.new(2, :spades),
        Card.new(1, :hearts)]
    d2 = d1.dup

    assert !d1.equal?(d2)
    assert d1.eql?(d2)
  end

  def test_shuffle_bang_modifies_self
    d1 = DeckOfCards.new [Card.new(1, :hearts), Card.new(2, :spades),
        Card.new(1, :hearts)]
    d2 = d1.dup

    # shuffle is random, so we might not get a different order.
    # Attempt multiple times to try and make sure we get an actual shuffle
    attempts = 10
    different = false

    while (attempts > 0 && !different)
      d2.shuffle!
      different = ! (d1 == d2)
      attempts -= 1
    end
    
    flunk "shuffle didn't create a different order" unless different
  end

  def test_shuffle_returns_new_deck
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)

    d1 = DeckOfCards.new [c1, c2, c3]

    d2 = d1.shuffle

    assert !(d1.equal? d2)
  end

  def test_shuffled_deck_has_same_size
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)

    d1 = DeckOfCards.new [c1, c2, c3]

    d2 = d1.shuffle

    assert_equal d1.size, d2.size
  end

  def test_shuffled_deck_has_same_cards
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)

    d1 = DeckOfCards.new [c1, c2, c3]

    d2 = d1.shuffle

    assert are_contents_the_same?(d1, d2)
  end

  def test_shuffled_deck_changes_order
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)

    d1 = DeckOfCards.new [c1, c2, c3]

    # shuffle is random, so we might not get a different order.
    # Attempt multiple times to try and make sure we get an actual shuffle
    attempts = 10
    different = false

    while (attempts > 0 && !different)
      d2 = d1.shuffle
      different = ! (d1 == d2)
      attempts -= 1
    end

    flunk "shuffle didn't create a different order" unless different
  end

  def test_equality_using_eql
    d1 = DeckOfCards.new [Card.new(1, :hearts), Card.new(2, :spades),
        Card.new(1, :hearts)]
    d2 = DeckOfCards.new [Card.new(1, :hearts), Card.new(2, :spades),
        Card.new(1, :hearts)]

    assert d1.eql? d2
    assert d2.eql? d1
  end

  def test_inequality_using_eql
    d1 = DeckOfCards.new [Card.new(1, :hearts), Card.new(2, :spades),
        Card.new(1, :hearts)]
    d2 = DeckOfCards.new [Card.new(1, :clubs), Card.new(2, :spades),
        Card.new(1, :hearts)]

    assert !(d1.eql? d2)
    assert !(d2.eql? d1)
  end

  def test_default_deck
    d = DeckOfCards.default_deck
    assert d.is_full_deck?
  end

  def test_shuffled_deck
    d = DeckOfCards.default_deck
    s = DeckOfCards.shuffled_deck
    assert s.is_full_deck?
    assert d != s
  end

  def test_full_deck_when_full
    d = DeckOfCards.new default_deck_cards_array
    assert d.is_full_deck?
  end

  def test_full_deck_when_not_full
    cards = default_deck_cards_array
    cards.pop(2)
    d = DeckOfCards.new cards
    assert !(d.is_full_deck?)
  end

  def test_remove_cards
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3, c4, c5]
    d2 = d1.remove_cards(1, 2)

    assert ! d1.equal?(d2)
    assert d1 != d2

    assert_equal 3, d2.size
    assert_equal c1, d2.card(0)
    assert_equal c4, d2.card(1)
    assert_equal c5, d2.card(2)
  end

  def test_remove_cards_bang
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3, c4, c5]
    rc1, rc2 = d1.remove_cards!(1, 2)

    assert_equal 3, d1.size
    assert_equal c1, d1.card(0)
    assert_equal c4, d1.card(1)
    assert_equal c5, d1.card(2)
    assert_equal c2, rc1
    assert_equal c3, rc2
  end

  def test_insert_cards
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3]
    d2 = d1.insert_cards(1, c4, c5)

    assert ! d1.equal?(d2)
    assert d1 != d2

    assert_equal 5, d2.size
    assert_equal c1, d2.card(0)
    assert_equal c4, d2.card(1)
    assert_equal c5, d2.card(2)
    assert_equal c2, d2.card(3)
    assert_equal c3, d2.card(4)
  end

  def test_insert_cards_bang
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3]
    d1.insert_cards!(1, c4, c5)

    assert_equal 5, d1.size
    assert_equal c1, d1.card(0)
    assert_equal c4, d1.card(1)
    assert_equal c5, d1.card(2)
    assert_equal c2, d1.card(3)
    assert_equal c3, d1.card(4)
  end

  def test_pop_cards
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3, c4, c5]
    d2 = d1.pop_cards(2)

    assert ! d1.equal?(d2)
    assert d1 != d2

    assert_equal 3, d2.size
    assert_equal c1, d2.card(0)
    assert_equal c2, d2.card(1)
    assert_equal c3, d2.card(2)
  end

  def test_pop_cards_bang
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3, c4, c5]
    rc1, rc2 = d1.pop_cards!(2)

    assert_equal 3, d1.size
    assert_equal c1, d1.card(0)
    assert_equal c2, d1.card(1)
    assert_equal c3, d1.card(2)
    assert_equal c4, rc1
    assert_equal c5, rc2
  end

  def test_push_cards
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3]
    d2 = d1.push_cards(c4, c5)

    assert ! d1.equal?(d2)
    assert d1 != d2

    assert_equal 5, d2.size
    assert_equal c1, d2.card(0)
    assert_equal c2, d2.card(1)
    assert_equal c3, d2.card(2)
    assert_equal c4, d2.card(3)
    assert_equal c5, d2.card(4)
  end

  def test_push_cards_bang
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3]
    d1.push_cards!(c4, c5)

    assert_equal 5, d1.size
    assert_equal c1, d1.card(0)
    assert_equal c2, d1.card(1)
    assert_equal c3, d1.card(2)
    assert_equal c4, d1.card(3)
    assert_equal c5, d1.card(4)
  end

  def test_shift_cards
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3, c4, c5]
    d2 = d1.shift_cards(2)

    assert ! d1.equal?(d2)
    assert d1 != d2

    assert_equal 3, d2.size
    assert_equal c3, d2.card(0)
    assert_equal c4, d2.card(1)
    assert_equal c5, d2.card(2)
  end

  def test_shift_cards_bang
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3, c4, c5]
    rc1, rc2 = d1.shift_cards!(2)

    assert_equal 3, d1.size
    assert_equal c3, d1.card(0)
    assert_equal c4, d1.card(1)
    assert_equal c5, d1.card(2)
    assert_equal c1, rc1
    assert_equal c2, rc2
  end

  def test_unshift_cards
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3]
    d2 = d1.unshift_cards(c4, c5)

    assert ! d1.equal?(d2)
    assert d1 != d2

    assert_equal 5, d2.size
    assert_equal c4, d2.card(0)
    assert_equal c5, d2.card(1)
    assert_equal c1, d2.card(2)
    assert_equal c2, d2.card(3)
    assert_equal c3, d2.card(4)
  end

  def test_unshift_cards_bang
    c1 = Card.new(1, :hearts)
    c2 = Card.new(10, :spades)
    c3 = Card.new(3, :clubs)
    c4 = Card.new(5, :diamonds)
    c5 = Card.new(7, :diamonds)

    d1 = DeckOfCards.new [c1, c2, c3]
    d1.unshift_cards!(c4, c5)

    assert_equal 5, d1.size
    assert_equal c4, d1.card(0)
    assert_equal c5, d1.card(1)
    assert_equal c1, d1.card(2)
    assert_equal c2, d1.card(3)
    assert_equal c3, d1.card(4)
  end

  def default_deck_cards_array
    [
      Card.new(1, :hearts),
      Card.new(2, :hearts),
      Card.new(3, :hearts),
      Card.new(4, :hearts),
      Card.new(5, :hearts),
      Card.new(6, :hearts),
      Card.new(7, :hearts),
      Card.new(8, :hearts),
      Card.new(9, :hearts),
      Card.new(10, :hearts),
      Card.new(11, :hearts),
      Card.new(12, :hearts),
      Card.new(13, :hearts),
      Card.new(1, :spades),
      Card.new(2, :spades),
      Card.new(3, :spades),
      Card.new(4, :spades),
      Card.new(5, :spades),
      Card.new(6, :spades),
      Card.new(7, :spades),
      Card.new(8, :spades),
      Card.new(9, :spades),
      Card.new(10, :spades),
      Card.new(11, :spades),
      Card.new(12, :spades),
      Card.new(13, :spades),
      Card.new(1, :clubs),
      Card.new(2, :clubs),
      Card.new(3, :clubs),
      Card.new(4, :clubs),
      Card.new(5, :clubs),
      Card.new(6, :clubs),
      Card.new(7, :clubs),
      Card.new(8, :clubs),
      Card.new(9, :clubs),
      Card.new(10, :clubs),
      Card.new(11, :clubs),
      Card.new(12, :clubs),
      Card.new(13, :clubs),
      Card.new(1, :diamonds),
      Card.new(2, :diamonds),
      Card.new(3, :diamonds),
      Card.new(4, :diamonds),
      Card.new(5, :diamonds),
      Card.new(6, :diamonds),
      Card.new(7, :diamonds),
      Card.new(8, :diamonds),
      Card.new(9, :diamonds),
      Card.new(10, :diamonds),
      Card.new(11, :diamonds),
      Card.new(12, :diamonds),
      Card.new(13, :diamonds)
    ]
  end
end
