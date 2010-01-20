require 'turn/turn'

# Represents a turn moving cards between two tableaus
class TableauToTableauTurn < Turn
  attr_reader :from_tableau_index
  attr_reader :to_tableau_index
  attr_reader :num_to_move

  # Initializes the turn.  This takes the board to act on, the indecies of the
  # tableaus to move between, and the number of cards to move.
  def initialize(board, from_tableau_index, to_tableau_index, num_to_move)
    super(board)
    @from_tableau_index = from_tableau_index
    @to_tableau_index = to_tableau_index
    @num_to_move = num_to_move
  end

  def to_s
    "Move #{@num_to_move} cards from tableau #{@from_tableau_index} to " +
    "tableau #{@to_tableau_index}"
  end

protected
  def apply_turn(board)
    board.move_between_tableaus!(@from_tableau_index, @to_tableau_index,
        @num_to_move)
  end
end
