require 'turn/turn'

# Represents a turn moving the top waste card to a tableau
class WasteToTableauTurn < Turn
  attr_reader :to_tableau_index

  # Initializes the turn.  This takes the board to act on and the index of the
  # tableau to act on.
  def initialize(board, to_tableau_index)
    super(board)
    @to_tableau_index = to_tableau_index
  end

  def to_s
    "Move top waste card to tableau #{@to_tableau_index}"
  end

protected
  def apply_turn(board)
    board.move_top_waste_card_to_tableau!(@to_tableau_index)
  end
end
