$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'foundation'

class FoundationTest < Test::Unit::TestCase
  def test_dup
    cards = [Card.get(Card::ACE, :diamonds),
        Card.get(2, :diamonds)];

    foundation1 = Foundation.new cards, :diamonds
    foundation2 = foundation1.dup

    assert ! foundation1.equal?(foundation2)
    assert_equal foundation1, foundation2
  end
end
