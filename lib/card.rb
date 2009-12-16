class Card
  attr_reader :value, :suit

  ACE=1
  JACK=11
  QUEEN=12
  KING=13

  def initialize(card_value, card_suit)
    fail "Invalid suit: #{card_suit}" unless validate_card(card_suit)
    fail "Invalid value: #{card_value}" unless validate_value(card_value)
    @value = card_value
    @suit = card_suit
  end

  def eql?(o)
    return false unless o.is_a?(Card)
    return o.value == @value && o.suit == @suit
  end

  def ==(o)
    return true if equal?(0)

    begin
      return o.value == @value && o.suit == @suit
    rescue Exception => ex
      return false
    end
  end

  def hash
    @value.hash ^ @suit.hash
  end

  def to_s
    "#{value} of #{suit}"
  end

protected
  def validate_card(c)
    [:hearts, :spades, :clubs, :diamonds].include?(c)
  end

  def validate_value(v)
    (1..13).to_a.include?(v)
  end
end
