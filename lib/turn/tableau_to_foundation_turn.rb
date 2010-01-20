require 'turn/turn'

# Represents a turn moving the bottom card from a tableau to a foundation.
class TableauToFoundationTurn < Turn
  attr_reader :from_tableau_index

  # Initializes the turn.  This takes the board to act on and the index of the
  # tableau to act on.
  def initialize(board, from_tableau_index)
    super(board)
    @from_tableau_index = from_tableau_index
  end

  def to_s
    "Move bottom card from tableau #{@from_tableau_index} to a foundation"
  end

protected
  def apply_turn(board)
    board.move_from_tableau_to_foundation!(@from_tableau_index)
  end
end
