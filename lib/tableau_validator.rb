require "card.rb"

# Validator for the main stacks (tableaus) used in the solitaire board
class TableauStackValidator
  # Gets the default instance of TableauStackValidator.  Generally you should
  # use this to get a TableauStackValidator so to save memory and allow equality
  # checks to work.
  def self.get
    return @default_instance unless @default_instance.nil?
    @default_instance = TableauStackValidator.new
  end

  def is_valid_stack?(stack)
    return true if stack.size == 0

    prev = nil
    valid = true

    stack.each do |card|
      if !prev.nil?
        valid = is_valid_transition?(prev, card)
      end

      prev = card
      break unless valid
    end

    valid
  end

  def can_append_card?(stack, card)
    is_valid_transition?(stack.bottom, card)
  end

  def can_append?(top_stack,bottom_stack)
    return false unless is_valid_stack? top_stack
    return false unless is_valid_stack? bottom_stack

    is_valid_transition? top_stack.bottom, bottom_stack.top 
  end

protected
  def is_valid_transition?(top, bottom)
    if top.nil?
      return (bottom.nil? || (bottom.value == Card::KING))
    end
    return false if top.value == Card::ACE
    return false if bottom.value == Card::ACE
    are_cards_sequential?(top, bottom)
  end

  def are_cards_sequential?(top, bottom)
    return false if top.value != bottom.value + 1
    VALID_SUIT_TRANSITIONS[top.suit].include?(bottom.suit)
  end

  # The valid suit transitions
  VALID_SUIT_TRANSITIONS = { :hearts => [:clubs, :spades],
    :diamonds => [:clubs, :spades],
    :clubs => [:hearts, :diamonds],
    :spades => [:hearts, :diamonds] }
end
