require 'solver'


class BreadthFirstSolver < Solver
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
    # tree requires non-equal objects to not have a sort value of 0.  The
    # easiest thing to do is to use the hash value and then make sure that
    # they can never be the same.  It's a hack, but the best I've got for
    # now.
    my_hash = board1.hash
    their_hash = board2.hash
    if my_hash == their_hash
      their_hash += 1
    end
    my_hash <=> their_hash
  end
end
