require 'solver'

# Solver implementation that sorts based on the estimated distance from the
# solution.  This essentially runs a depth-first search.
#
# This solver is *not* guaranteed to give you the optimal solution.  However,
# unlike the TurnCountSolver it should generally find a solution (if one
# exists) fairly quickly.  Unsolvable boards will still take just as long as
# the TurnCountSolver though, as both cases have to exhaust the entire graph
# of board states before it can say the board is unsolvable.
class DistanceFromSolutionSolver < Solver
  def initialize(initial_board)
    super(initial_board) { |b1, b2| board_compare b1, b2 }
  end

  def board_compare(board1, board2)
    c = get_distance_from_solution(board1) <=> get_distance_from_solution(board2)

    return c unless c == 0

    # Any boards with the same distance are considered equal as far as the
    # algorithm is concerned.  However the sorted queue requires only actually
    # equal objects to return 0 for the <=> operator, so we'll just compare the
    # object IDs.
    board1.object_id <=> board2.object_id
  end

  # Calculates the distance a board is from the solution
  def get_distance_from_solution(board)
    num_hidden = board.num_hidden
    num_in_foundations = board.num_in_foundations
    num_avaialble = 52 - num_in_foundations - num_hidden

    # Hidden cards are more problematic than cards that are immediately
    # available or in the stock, so we'll weight those double.
    #
    # We also want to discourage moving cards off of the foundations when
    # possible, so we give a little extra weight to having cards on the
    # foundations.
    num_avaialble + (2 * num_hidden) - (1.5 * num_in_foundations)
  end
end
