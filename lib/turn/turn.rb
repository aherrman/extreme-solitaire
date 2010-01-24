require 'hash_helper'

# Represents a single turn in the game.
class Turn
  include HashHelper

  # Initializes the turn.
  def initialize(board)
    @original_board = board
    @finalized = false
  end

  # The board the turn is acting on
  def board
    @original_board.dup
  end

  # Trys the turn.  This returns the new board with the turn applied but
  # before being finalized.
  def try_turn
    raise "Turn has already been finalized on original board" if @finalized
    new_board = @original_board.dup
    apply_turn(new_board)
    new_board
  end

  # Applies the turn to the original board and finalizes it, returning the new
  # board.
  def do_turn
    raise "Turn has already been finalized on original board" if @finalized
    board = try_turn
    board.finalize_move!
    board
  end

  # Applies the turn to the original board
  def do_turn!
    raise "Turn has already been finalized on original board" if @finalized
    apply_turn(@original_board)
    @original_board.finalize_move!
    @finalized = true
    @original_board
  end

  def hash
    @original_board.hash
  end

protected

  # Applies the turn to the board passed in.  This needs to be implemented by
  # the various turn implementations
  def apply_turn(board)
    raise "Base turn class doesn't know what turn to run!"
  end
end
