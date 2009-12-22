# Simple stack validator that allows anything
class AnythingGoesStackValidator
  def can_append?(top_stack, bottom_stack)
    true
  end

  def can_append_card?(stack, card)
    true
  end

  def is_valid_stack?(stack)
    true
  end
end
