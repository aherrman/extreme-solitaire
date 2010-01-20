# Represents a single turn in the game.
class Turn
  # Initializes the turn.
  def initialize(board)
    @original_board = board
  end

  # Trys the turn.  This returns the new board with the turn applied but
  # before being finalized.
  def try_turn
    new_board = @original_board.dup
    apply_turn(new_board)
    new_board
  end

  # Applies the turn to the original board and finalizes it, returning the new
  # board.
  def do_turn
    board = try_turn
    board.finalize_move!
    board
  end

protected
  # Applies the turn to the board passed in.  This needs to be implemented by
  # the various turn implementations
  def apply_turn(board)
    raise "Base turn class doesn't know what turn to run!"
  end
end
