# 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'card'

class CardTest < Test::Unit::TestCase
  def test_valid_cards_dont_throw_exceptions
    Card::VALID_SUITS.each { |suit|
      Card::VALID_VALUES.each { |val|
        c = Card.new val, suit
      }
    }
  end

  def test_invalid_value_throws_exceptions
    assert_raise(RuntimeError) {
      c = Card.new 15, :hearts
    }
  end

  def test_invalid_suit_throws_exceptions
    assert_raise(RuntimeError) {
      c = Card.new 10, :foo
    }
  end

  def test_identity_equality_using_double_equals
    c = Card.new 10, :hearts

    assert c == c
  end

  def test_identity_equality_using_eql
    c = Card.new 10, :hearts

    assert c.eql?(c)
  end

  def test_equality_using_double_equals
    c1 = Card.new 10, :hearts
    c2 = Card.new 10, :hearts

    assert c1 == c2
    assert c2 == c1
  end

  def test_equality_using_eql
    c1 = Card.new 10, :hearts
    c2 = Card.new 10, :hearts

    assert c1.eql?(c2)
    assert c2.eql?(c1)
  end

  def test_inequality_when_value_is_different_using_double_equals
    c1 = Card.new 11, :hearts
    c2 = Card.new 10, :hearts

    assert c1 != c2
    assert c2 != c1
  end

  def test_inequality_when_suit_is_different_using_double_equals
    c1 = Card.new 10, :hearts
    c2 = Card.new 10, :clubs

    assert c1 != c2
    assert c2 != c1
  end

  def test_inequality_when_both_are_different_using_double_equals
    c1 = Card.new 10, :hearts
    c2 = Card.new 12, :clubs

    assert c1 != c2
    assert c2 != c1
  end

  def test_inequality_when_value_is_different_using_eql
    c1 = Card.new 11, :hearts
    c2 = Card.new 10, :hearts

    assert ! (c1.eql? c2)
    assert ! (c2.eql? c1)
  end

  def test_inequality_when_suit_is_different_using_eql
    c1 = Card.new 10, :hearts
    c2 = Card.new 10, :clubs

    assert ! (c1.eql? c2)
    assert ! (c2.eql? c1)
  end

  def test_inequality_when_both_are_different_using_eql
    c1 = Card.new 10, :hearts
    c2 = Card.new 12, :clubs

    assert ! (c1.eql? c2)
    assert ! (c2.eql? c1)
  end

  def test_equal_cards_have_same_hash
    c1 = Card.new 10, :hearts
    c2 = Card.new 10, :hearts

    assert_equal c1.hash, c2.hash
  end

  def test_double_equal_ignores_type
    c1 = Card.new 10, :hearts
    c2 = Object.new
    def c2.value
      10 
    end
    def c2.suit
      :hearts
    end

    assert c1 == c2
  end

  def test_eql_checks_type
    c1 = Card.new 10, :hearts
    c2 = Object.new
    def c2.value
      10
    end
    def c2.suit
      :hearts
    end

    assert !(c1.eql?(c2))
  end

  def test_different_cards_have_different_hash
    hash_results = {}

    Card::VALID_SUITS.each { |suit|
      Card::VALID_VALUES.each { |val|
        c = Card.new val, suit
        h = c.hash

        hash_results[h] = 0 if hash_results[h].nil?
        hash_results[h] += 1
      }
    }

    assert_equal [], hash_results.values.select() { |v| v > 1 }
  end

  def test_to_s
    c = Card.new 2, :hearts
    assert_equal "2 of hearts", c.to_s
  end
end
