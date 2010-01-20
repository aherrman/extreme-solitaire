require 'turn/turn'

# Represents a turn flipping the next stock card or resetting them if the stock
# is empty.
class FlipStockTurn < Turn
  # Initializes the turn.  This takes the board to act on.
  def initialize(board)
    super(board)
  end

  def to_s
    "Flip stock card"
  end

protected
  def apply_turn(board)
    board.flip_next_stock_card!
  end
end
