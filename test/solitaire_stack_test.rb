# 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'solitaire_stack'

class SolitaireStackTest < Test::Unit::TestCase
  def test_can_create_valid_stack
    cards = [
      Card.get(13, :hearts),
      Card.get(12, :clubs),
      Card.get(11, :diamonds),
    ]

    s = SolitaireStack.new cards

    assert_equal cards[0], s[0]
    assert_equal cards[1], s[1]
    assert_equal cards[2], s[2]
  end

  def test_cannot_create_invalid_stack
    cards = [
      Card.get(13, :hearts),
      Card.get(13, :clubs),
    ]

    assert_raise(RuntimeError) {
      SolitaireStack.new cards
    }
  end

  def test_can_stacks_be_merged
    cards1 = [
      Card.get(13, :hearts),
      Card.get(12, :clubs),
    ]

    cards2 = [
      Card.get(11, :diamonds),
    ]

    s1 = SolitaireStack.new cards1
    s2 = SolitaireStack.new cards2

    assert SolitaireStack.can_stacks_be_merged?(s1, s2)
  end

  def test_can_append_when_valid
    cards1 = [
      Card.get(13, :hearts),
      Card.get(12, :clubs),
    ]

    cards2 = [
      Card.get(11, :diamonds),
    ]

    s1 = SolitaireStack.new cards1
    s2 = DeckOfCards.new cards2

    assert s1.can_append?(s2)
  end

  def test_can_append_when_result_would_be_bad
    cards1 = [
      Card.get(13, :hearts),
      Card.get(12, :clubs),
    ]

    cards2 = [
      Card.get(10, :diamonds),
    ]

    s1 = SolitaireStack.new cards1
    s2 = SolitaireStack.new cards2

    assert ! s1.can_append?(s2)
  end

  def test_can_append_when_deck_is_invalid
    cards1 = [
      Card.get(13, :hearts),
      Card.get(12, :clubs),
    ]

    cards2 = [
      Card.get(10, :diamonds),
      Card.get(12, :diamonds),
    ]

    s1 = SolitaireStack.new cards1
    s2 = DeckOfCards.new cards2

    assert ! s1.can_append?(s2)
  end

  def test_can_append_card_when_valid
    cards = [
      Card.get(13, :hearts),
      Card.get(12, :clubs),
    ]
    c = Card.get 11, :diamonds

    s1 = SolitaireStack.new cards

    assert s1.can_append_card?(c)
  end

  def test_can_append_card_when_invalid
    cards = [
      Card.get(13, :hearts),
      Card.get(12, :clubs),
    ]
    c = Card.get 2, :diamonds

    s1 = SolitaireStack.new cards

    assert ! s1.can_append_card?(c)
  end

  def test_stack_cannot_be_just_ace
    cards = [ Card.get(1, :hearts) ]

    assert_raise(RuntimeError) {
      SolitaireStack.new cards
    }
  end

  def test_stack_cannot_have_aces
    cards = [
      Card.get(2, :spades),
      Card.get(1, :hearts)
    ]

    assert_raise(RuntimeError) {
      SolitaireStack.new cards
    }
  end

  def test_push_cards_when_valid
    cards1 = [
      Card.get(13, :hearts),
      Card.get(12, :clubs),
    ]
    c1 = Card.get(11, :diamonds)
    c2 = Card.get(10, :clubs)

    s1 = SolitaireStack.new cards1
    s2 = s1.push_cards(c1, c2)

    assert_equal s2[2], c1
    assert_equal s2[3], c2
  end

  def test_push_cards_when_cards_are_valid_but_append_isnt
    cards1 = [
      Card.get(13, :hearts),
      Card.get(12, :clubs),
    ]
    c1 = Card.get(10, :diamonds)
    c2 = Card.get(9, :clubs)

    s1 = SolitaireStack.new cards1

    assert_raise(RuntimeError) {
      s1.push_cards(c1, c2)
    }
  end

  def test_push_cards_when_cards_are_invalid
    cards1 = [
      Card.get(13, :hearts),
      Card.get(12, :clubs),
    ]
    c1 = Card.get(11, :diamonds)
    c2 = Card.get(9, :clubs)

    s1 = SolitaireStack.new cards1

    assert_raise(RuntimeError) {
      s1.push_cards(c1, c2)
    }
  end

  def test_append_deck_when_valid
    c1 = Card.get(13, :hearts)
    c2 = Card.get(12, :clubs)
    c3 = Card.get(11, :diamonds)
    c4 = Card.get(10, :clubs)

    s1 = SolitaireStack.new [c1, c2]
    s2 = SolitaireStack.new [c3, c4]

    s3 = s1.append_deck(s2)

    assert_equal s3[0], c1
    assert_equal s3[1], c2
    assert_equal s3[2], c3
    assert_equal s3[3], c4
  end

  def test_append_deck_when_valid_but_not_solitaire_stack
    c1 = Card.get(13, :hearts)
    c2 = Card.get(12, :clubs)
    c3 = Card.get(11, :diamonds)
    c4 = Card.get(10, :clubs)

    s1 = SolitaireStack.new [c1, c2]
    s2 = DeckOfCards.new [c3, c4]

    s3 = s1.append_deck(s2)

    assert_equal s3[0], c1
    assert_equal s3[1], c2
    assert_equal s3[2], c3
    assert_equal s3[3], c4
  end

  def test_append_deck_when_invalid_append
    c1 = Card.get(13, :hearts)
    c2 = Card.get(12, :clubs)
    c3 = Card.get(9, :diamonds)
    c4 = Card.get(8, :clubs)

    s1 = SolitaireStack.new [c1, c2]
    s2 = SolitaireStack.new [c3, c4]

    assert_raise(RuntimeError) {
      s1.append_deck(s2)
    }
  end

  def test_append_deck_when_invalid_append_and_not_solitaire_stack
    c1 = Card.get(13, :hearts)
    c2 = Card.get(12, :clubs)
    c3 = Card.get(9, :diamonds)
    c4 = Card.get(8, :clubs)

    s1 = SolitaireStack.new [c1, c2]
    s2 = DeckOfCards.new [c3, c4]

    assert_raise(RuntimeError) {
      s1.append_deck(s2)
    }
  end

  def test_append_deck_when_invalid_second_deck
    c1 = Card.get(13, :hearts)
    c2 = Card.get(12, :clubs)
    c3 = Card.get(10, :diamonds)
    c4 = Card.get(8, :clubs)

    s1 = SolitaireStack.new [c1, c2]
    s2 = DeckOfCards.new [c3, c4]

    assert_raise(RuntimeError) {
      s1.append_deck(s2)
    }
  end

  def test_append_deck_returns_new_stack
    c1 = Card.get(13, :hearts)
    c2 = Card.get(12, :clubs)
    c3 = Card.get(11, :diamonds)
    c4 = Card.get(10, :clubs)

    s1 = SolitaireStack.new [c1, c2]
    s2 = SolitaireStack.new [c3, c4]

    s3 = s1.append_deck(s2)

    assert ! s1.equal?(s3)
    assert ! s2.equal?(s3)
    assert s3.is_a?(SolitaireStack)
  end

  def test_append_deck_doesnt_change_original
    c1 = Card.get(13, :hearts)
    c2 = Card.get(12, :clubs)
    c3 = Card.get(11, :diamonds)
    c4 = Card.get(10, :clubs)

    s1 = SolitaireStack.new [c1, c2]
    s1d = s1.dup
    s2 = SolitaireStack.new [c3, c4]
    s2d = s2.dup

    s1.append_deck(s2)

    assert_equal s1, s1d
    assert_equal s2, s2d
  end

  def test_push_cards_returns_new_stack
    c1 = Card.get(13, :hearts)
    c2 = Card.get(12, :clubs)
    c3 = Card.get(11, :diamonds)
    c4 = Card.get(10, :clubs)

    s1 = SolitaireStack.new [c1, c2]

    s2 = s1.push_cards(c3, c4)

    assert ! s1.equal?(s2)
    assert s2.is_a?(SolitaireStack)
  end

  def test_push_cards_doesnt_change_original
    c1 = Card.get(13, :hearts)
    c2 = Card.get(12, :clubs)
    c3 = Card.get(11, :diamonds)
    c4 = Card.get(10, :clubs)

    s1 = SolitaireStack.new [c1, c2]
    s1d = s1.dup

    s1.push_cards(c3, c4)

    assert_equal s1, s1d
  end

  def test_dup_returns_correct_type
    c1 = Card.get(13, :hearts)
    c2 = Card.get(12, :clubs)

    s1 = SolitaireStack.new [c1, c2]
    s2 = s1.dup

    assert_equal s1, s2
    assert !s1.equal?(s2)
    assert s2.is_a?(SolitaireStack)
  end

  def test_push_cards_when_cards_are_valid_but_append_isnt
    cards1 = [
      Card.get(13, :hearts),
      Card.get(12, :clubs),
    ]
    c1 = Card.get(10, :diamonds)
    c2 = Card.get(9, :clubs)

    s1 = SolitaireStack.new cards1

    assert_raise(RuntimeError) {
      s1.push_cards(c1, c2)
    }
  end

  def test_push_cards_when_cards_are_invalid
    cards1 = [
      Card.get(13, :hearts),
      Card.get(12, :clubs),
    ]
    c1 = Card.get(11, :diamonds)
    c2 = Card.get(9, :clubs)

    s1 = SolitaireStack.new cards1

    assert_raise(RuntimeError) {
      s1.push_cards(c1, c2)
    }
  end

  def test_is_valid_suit_transition
    assert !SolitaireStack.is_valid_suit_transition(:hearts, :hearts)
    assert !SolitaireStack.is_valid_suit_transition(:hearts, :diamonds)
    assert !SolitaireStack.is_valid_suit_transition(:clubs, :clubs)
    assert !SolitaireStack.is_valid_suit_transition(:clubs, :spades)
    assert !SolitaireStack.is_valid_suit_transition(:diamonds, :hearts)
    assert !SolitaireStack.is_valid_suit_transition(:diamonds, :diamonds)
    assert !SolitaireStack.is_valid_suit_transition(:spades, :clubs)
    assert !SolitaireStack.is_valid_suit_transition(:spades, :spades)

    assert SolitaireStack.is_valid_suit_transition(:hearts, :clubs)
    assert SolitaireStack.is_valid_suit_transition(:hearts, :spades)
    assert SolitaireStack.is_valid_suit_transition(:clubs, :hearts)
    assert SolitaireStack.is_valid_suit_transition(:clubs, :diamonds)
    assert SolitaireStack.is_valid_suit_transition(:diamonds, :clubs)
    assert SolitaireStack.is_valid_suit_transition(:diamonds, :spades)
    assert SolitaireStack.is_valid_suit_transition(:spades, :hearts)
    assert SolitaireStack.is_valid_suit_transition(:spades, :diamonds)
  end

  # Generate individual tests for each valid value transition instead of using
  # a single test to test all of them
  (2..12).to_a.each { |i|
    top = i + 1
    bottom = i
    s =  "def test_valid_value_transition_#{top}_#{bottom}\n"
    s << "  c1 = Card.get #{top}, :hearts\n"
    s << "  c2 = Card.get #{bottom}, :clubs\n"
    s << "  assert SolitaireStack.are_cards_sequential?(c1, c2)\n"
    s << "end\n"
    eval(s)
  }

  # test-related hack to get at valid transitions that are normaly protected
  class SST < SolitaireStack
    def self.valid_trans
      VALID_SUIT_TRANSITIONS
    end
  end

  # Generate individual tests for each valid suit transition instead of using
  # a single test to test all of them
  SST.valid_trans.each { |key, value|
    value.each { |v|
      s =  "def test_valid_suit_transition_#{key}_#{v}\n"
      s << "  c1 = Card.get 10, :#{key}\n"
      s << "  c2 = Card.get 9, :#{v}\n"
      s << "  assert SolitaireStack.are_cards_sequential?(c1, c2)\n"
      s << "end\n"
      eval(s)
    }
  }

end