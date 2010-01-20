require 'turn/turn'

# Represents a turn moving the top waste card to a foundation.
class WasteToFoundationTurn < Turn
  # Initializes the turn.  This takes the board to act on
  def initialize(board)
    super(board)
  end

  def to_s
    "Move top waste card to foundation"
  end

protected
  def apply_turn(board)
    board.move_top_waste_card_to_foundation!
  end
end
