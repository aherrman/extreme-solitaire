require 'solver'

# Solver implementation that sorts based on the turn count of the boards.  This
# causes a breadth-first search.  This solver is guaranteed to return the
# optimal solution.
#
# Due to the size of the problem space this solve method will generally not
# complete except in trivial situations.
class TurnCountSolver < Solver
  def initialize(initial_board)
    # TODO: Figure out the right syntax to pass this in directly
    super(initial_board) { |b1, b2| board_compare b1, b2 }
  end

  def board_compare(board1, board2)
    return 0 if board1.eql? board2

    comp = board1.turn_count <=> board2.turn_count
    return comp unless comp == 0

    # In theory the boards that have less hidden cards are closer to being
    # solved.  By sorting by the number of hidden cards left we'll end up
    # processing those first, hopefully getting us to the solution sooner.
    comp = board1.num_hidden <=> board2.num_hidden

    return comp unless comp == 0

    # Anything with the same turn count and number of hidden cards is
    # considered equal as far as the sorting for solving goes.  However, the
    # tree requires non-equal objects to not have a sort value of 0.
    # The quickest solution is to just use the object IDs of the boards.  This
    # should result in consistent ordering
    board1.object_id <=> board2.object_id
  end
end
