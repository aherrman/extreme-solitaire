require 'validated_stack'
require 'aces_stack_validator'
require 'solitaire_column'

class SolitaireBoard

  def initialize(deck)
    @diamonds = ValidatedStack.new [], AcesStackValidator.get(:diamonds)
    @hearts = ValidatedStack.new [], AcesStackValidator.get(:hearts)
    @clubs = ValidatedStack.new [], AcesStackValidator.get(:clubs)
    @spades = ValidatedStack.new [], AcesStackValidator.get(:spades)

    @stacks = []

    (1..7).each do |i|
      deck, stack = deck.remove_stack(i)

      @stacks.push SolitaireColumn.new stack
    end

    @remaining_cards = deck
  end

end
