# 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'stack_of_cards'
require 'enum_helpers'

class StackOfCardsTest < Test::Unit::TestCase
  def test_size
    d = StackOfCards.new [Card.get(1, :hearts), Card.get(2, :spades)]

    assert_equal 2, d.size
  end

  def test_card
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    d = StackOfCards.new [c1, c2, c3]

    assert_equal c1, d.card(0)
    assert_equal c2, d.card(1)
    assert_equal c3, d.card(2)
  end

  def test_index_array_style_access
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    d = StackOfCards.new [c1, c2, c3]
    
    c = d[1]
    
    assert_equal c, c2
  end

  def test_top
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    d = StackOfCards.new [c1, c2, c3]

    assert_equal c1, d.top
  end

  def test_bottom
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    d = StackOfCards.new [c1, c2, c3]

    assert_equal c3, d.bottom
  end

  def test_start_len_array_style_access
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)
    c4 = Card.get(5, :diamonds)
    c5 = Card.get(7, :diamonds)

    d1 = StackOfCards.new [c1, c2, c3, c4, c5]

    rc1, rc2, rc3 = d1[1, 3]
    assert_equal rc1, c2
    assert_equal rc2, c3
    assert_equal rc3, c4
  end

  def test_range_array_style_access
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)
    c4 = Card.get(5, :diamonds)
    c5 = Card.get(7, :diamonds)

    d1 = StackOfCards.new [c1, c2, c3, c4, c5]

    rc1, rc2 = d1[1..2]
    assert_equal rc1, c2
    assert_equal rc2, c3
  end

  def test_cannot_modify_using_array_syntax
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)
    c4 = Card.get(5, :diamonds)
    c5 = Card.get(7, :diamonds)

    d1 = StackOfCards.new [c1, c2, c3, c4, c5]

    assert_raise(NoMethodError) {
      d1[2] = Card.get(2, :hearts)
    }
  end

  def test_modifying_arg_array_doesnt_change_stack
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    a = [c1, c2, c3]

    d = StackOfCards.new a

    a[1] = Card.get 5, :diamonds

    assert_equal c1, d.card(0)
    assert_equal c2, d.card(1)
    assert_equal c3, d.card(2)
  end

  #def test_is_standard_stack_when_standard
  #  d = StackOfCards.new [Card.get(1, :hearts), Card.get(2, :spades)]

  #  assert d.is_standard_stack?
  #end

  #def test_is_standard_stack_when_not_standard
  #  d = StackOfCards.new [Card.get(1, :hearts), Card.get(2, :spades),
  #      Card.get(1, :hearts)]

  #  assert !d.is_standard_stack?
  #end

  def test_dup
    d1 = StackOfCards.new [Card.get(1, :hearts), Card.get(2, :spades),
        Card.get(1, :hearts)]
    d2 = d1.dup

    assert !d1.equal?(d2)
    assert d1.eql?(d2)
    assert d1.is_a?(StackOfCards)
  end

  def test_changing_dup_doesnt_change_original
    # default stack is large enough that a shuffle should pretty much always
    # result in a change
    d1 = StackOfCards.default_stack
    d2 = d1.dup

    d2.shuffle!

    assert d1 != d2
  end

  def test_shuffle_bang_modifies_self
    d1 = StackOfCards.new [Card.get(1, :hearts), Card.get(2, :spades),
        Card.get(1, :hearts)]
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

  def test_shuffle_returns_new_stack
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    d1 = StackOfCards.new [c1, c2, c3]

    d2 = d1.shuffle

    assert !(d1.equal? d2)
  end

  def test_shuffled_stack_has_same_size
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    d1 = StackOfCards.new [c1, c2, c3]

    d2 = d1.shuffle

    assert_equal d1.size, d2.size
  end

  def test_shuffled_stack_has_same_cards
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    d1 = StackOfCards.new [c1, c2, c3]

    d2 = d1.shuffle

    assert are_contents_the_same?(d1, d2)
  end

  def test_shuffled_stack_changes_order
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    d1 = StackOfCards.new [c1, c2, c3]

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
    d1 = StackOfCards.new [Card.get(1, :hearts), Card.get(2, :spades),
        Card.get(1, :hearts)]
    d2 = StackOfCards.new [Card.get(1, :hearts), Card.get(2, :spades),
        Card.get(1, :hearts)]

    assert d1.eql? d2
    assert d2.eql? d1
  end

  def test_inequality_using_eql
    d1 = StackOfCards.new [Card.get(1, :hearts), Card.get(2, :spades),
        Card.get(1, :hearts)]
    d2 = StackOfCards.new [Card.get(1, :clubs), Card.get(2, :spades),
        Card.get(1, :hearts)]

    assert !(d1.eql? d2)
    assert !(d2.eql? d1)
  end

  #def test_default_stack
  #  d = StackOfCards.default_stack
  #  assert d.is_full_stack?
  #end

  #def test_shuffled_stack
  #  d = StackOfCards.default_stack
  #  s = StackOfCards.shuffled_stack
  #  assert s.is_full_stack?
  #  assert d != s
  #end

  #def test_full_stack_when_full
  #  d = StackOfCards.new default_stack_cards_array
  #  assert d.is_full_stack?
  #end

  #def test_full_stack_when_not_full
  #  cards = default_stack_cards_array
  #  cards.pop(2)
  #  d = StackOfCards.new cards
  #  assert !(d.is_full_stack?)
  #end

  def test_append_card
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    d1 = StackOfCards.new [c1, c2]
    d2 = d1.append_card c3

    assert_equal 3, d2.size
    assert_equal c1, d2[0]
    assert_equal c2, d2[1]
    assert_equal c3, d2[2]
  end

  def test_append_card_returns_a_new_stack
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    d1 = StackOfCards.new [c1, c2]
    d2 = d1.append_card c3

    assert_equal 2, d1.size
    assert d1 != d2
  end

  def test_remove_card
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    s1 = StackOfCards.new [c1, c2, c3]
    s2, removed = s1.remove_card

    assert_equal 2, s2.size
    assert_equal c1, s2[0]
    assert_equal c2, s2[1]
    assert_equal c3, removed
  end

  def test_remove_card_returns_a_new_stack
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)

    s1 = StackOfCards.new [c1, c2, c3]
    s2, removed = s1.remove_card

    assert_equal 3, s1.size
    assert s1 != s2
  end

  def test_append_stack
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)
    c4 = Card.get(5, :diamonds)
    c5 = Card.get(7, :diamonds)

    d1 = StackOfCards.new [c1, c2, c3]
    d2 = StackOfCards.new [c4, c5]

    # back up d1 and d2 so we can make sure they weren't changed
    d1d = d1.dup
    d2d = d2.dup

    d3 = d1.append_stack d2

    assert_equal d1, d1d
    assert_equal d2, d2d
    assert d3 != d1
    assert d3 != d2

    assert_equal 5, d3.size
    assert_equal c1, d3[0]
    assert_equal c2, d3[1]
    assert_equal c3, d3[2]
    assert_equal c4, d3[3]
    assert_equal c5, d3[4]
  end

  def test_remove_stack
    c1 = Card.get(1, :hearts)
    c2 = Card.get(10, :spades)
    c3 = Card.get(3, :clubs)
    c4 = Card.get(5, :diamonds)
    c5 = Card.get(7, :diamonds)

    d1 = StackOfCards.new [c1, c2, c3, c4, c5]
    d2, popped = d1.remove_stack(2)

    assert ! d1.equal?(d2)
    assert d1 != d2

    assert_equal 3, d2.size
    assert_equal c1, d2[0]
    assert_equal c2, d2[1]
    assert_equal c3, d2[2]

    assert_equal 2, popped.size
    assert popped.is_a?(StackOfCards)
    assert_equal c4, popped[0]
    assert_equal c5, popped[1]
  end

  def default_stack_cards_array
    [
      Card.get(1, :hearts),
      Card.get(2, :hearts),
      Card.get(3, :hearts),
      Card.get(4, :hearts),
      Card.get(5, :hearts),
      Card.get(6, :hearts),
      Card.get(7, :hearts),
      Card.get(8, :hearts),
      Card.get(9, :hearts),
      Card.get(10, :hearts),
      Card.get(11, :hearts),
      Card.get(12, :hearts),
      Card.get(13, :hearts),
      Card.get(1, :spades),
      Card.get(2, :spades),
      Card.get(3, :spades),
      Card.get(4, :spades),
      Card.get(5, :spades),
      Card.get(6, :spades),
      Card.get(7, :spades),
      Card.get(8, :spades),
      Card.get(9, :spades),
      Card.get(10, :spades),
      Card.get(11, :spades),
      Card.get(12, :spades),
      Card.get(13, :spades),
      Card.get(1, :clubs),
      Card.get(2, :clubs),
      Card.get(3, :clubs),
      Card.get(4, :clubs),
      Card.get(5, :clubs),
      Card.get(6, :clubs),
      Card.get(7, :clubs),
      Card.get(8, :clubs),
      Card.get(9, :clubs),
      Card.get(10, :clubs),
      Card.get(11, :clubs),
      Card.get(12, :clubs),
      Card.get(13, :clubs),
      Card.get(1, :diamonds),
      Card.get(2, :diamonds),
      Card.get(3, :diamonds),
      Card.get(4, :diamonds),
      Card.get(5, :diamonds),
      Card.get(6, :diamonds),
      Card.get(7, :diamonds),
      Card.get(8, :diamonds),
      Card.get(9, :diamonds),
      Card.get(10, :diamonds),
      Card.get(11, :diamonds),
      Card.get(12, :diamonds),
      Card.get(13, :diamonds)
    ]
  end
end
