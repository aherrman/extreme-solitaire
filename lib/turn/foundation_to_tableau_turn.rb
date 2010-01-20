require 'turn/turn'

# Represents a turn moving a card from a foundation to a tableau.
class FoundationToTableauTurn < Turn
  attr_reader :to_tableau_index
  attr_reader :suit

  # Initializes the turn.  This takes the board to act on, the suit of the
  # foundation to move from, and the tableau to move to.
  def initialize(board, suit, to_tableau_index)
    super(board)
    @to_tableau_index = to_tableau_index
    @suit = suit
  end

  def to_s
    "Move card from #{@suit} foundation to tableau #{@to_tableau_index}"
  end

protected
  def apply_turn(board)
    board.move_from_foundation_to_tableau!(@suit, @to_tableau_index)
  end
end
