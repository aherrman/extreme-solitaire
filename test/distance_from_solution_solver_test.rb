$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'solitaire_board'
require 'solver'
require 'distance_from_solution_solver'

class DistanceFromSolutionSolverTest < Test::Unit::TestCase
  def test_solver_solves_already_solved_board
    diamonds = Foundation.build_foundation(13, :diamonds)
    clubs = Foundation.build_foundation(13, :clubs)
    hearts = Foundation.build_foundation(13, :hearts)
    spades = Foundation.build_foundation(13, :spades)

    state = {
      :diamonds_foundation => diamonds,
      :spades_foundation => spades,
      :hearts_foundation => hearts,
      :clubs_foundation => clubs
    }

    board = SolitaireBoard.new state

    solver = DistanceFromSolutionSolver.new board

    solver.solve

    assert solver.solution_exists?

    turns = solver.get_solution_turns
    assert_equal 0, turns.size
  end

  def test_solver_doesnt_allow_nill_board
    assert_raise(RuntimeError) {
      solver = DistanceFromSolutionSolver.new nil
    }
  end

  def test_solver_can_solve_simple_board
    diamonds = Foundation.build_foundation(13, :diamonds)
    clubs = Foundation.build_foundation(12, :clubs)
    hearts = Foundation.build_foundation(13, :hearts)
    spades = Foundation.build_foundation(13, :spades)

    used = StackOfCards.new [Card.get(13, :clubs)]

    state = {
      :diamonds_foundation => diamonds,
      :spades_foundation => spades,
      :hearts_foundation => hearts,
      :clubs_foundation => clubs,
      :waste => used,
    }

    board = SolitaireBoard.new state

    solver = DistanceFromSolutionSolver.new board

    solver.solve

    assert solver.solution_exists?

    turns = solver.get_solution_turns

    assert_equal 1, turns.size
    assert_equal WasteToFoundationTurn, turns[0].class
    assert_equal solver.start_board, turns[0].board

    new_board = turns[0].do_turn
    assert new_board.solved?
  end

  def test_solve_calls_progress_callback
    diamonds = Foundation.build_foundation(13, :diamonds)
    clubs = Foundation.build_foundation(12, :clubs)
    hearts = Foundation.build_foundation(13, :hearts)
    spades = Foundation.build_foundation(13, :spades)

    used = StackOfCards.new [Card.get(13, :clubs)]

    state = {
      :diamonds_foundation => diamonds,
      :spades_foundation => spades,
      :hearts_foundation => hearts,
      :clubs_foundation => clubs,
      :stock => used,
    }

    board = SolitaireBoard.new state

    solver = DistanceFromSolutionSolver.new board

    turn_count = 0

    solver.solve { |tc, queue_size, skipped|
      turn_count = tc
    }

    assert_equal 2, turn_count
  end

  def test_solve_obeys_max_count
    diamonds = Foundation.build_foundation(13, :diamonds)
    clubs = Foundation.build_foundation(11, :clubs)
    hearts = Foundation.build_foundation(12, :hearts)
    spades = Foundation.build_foundation(13, :spades)

    used = StackOfCards.new [Card.get(13, :clubs), Card.get(12, :clubs),
      Card.get(13, :hearts)]

    state = {
      :diamonds_foundation => diamonds,
      :spades_foundation => spades,
      :hearts_foundation => hearts,
      :clubs_foundation => clubs,
      :stock => used,
    }
    board = SolitaireBoard.new state

    solver = DistanceFromSolutionSolver.new board

    solver.solve 5

    assert ! solver.solved
    assert_equal 5, solver.processed
  end

  def test_solve_continues_where_it_left_off
    diamonds = Foundation.build_foundation(13, :diamonds)
    clubs = Foundation.build_foundation(11, :clubs)
    hearts = Foundation.build_foundation(12, :hearts)
    spades = Foundation.build_foundation(13, :spades)

    used = StackOfCards.new [Card.get(13, :clubs), Card.get(12, :clubs),
      Card.get(13, :hearts)]

    state = {
      :diamonds_foundation => diamonds,
      :spades_foundation => spades,
      :hearts_foundation => hearts,
      :clubs_foundation => clubs,
      :stock => used,
    }

    board = SolitaireBoard.new state

    solver = DistanceFromSolutionSolver.new board

    solver.solve 5
    solver.solve

    assert solver.solved
  end

  def test_solver_detects_unsolvable_board
    diamonds = Foundation.build_foundation(10, :diamonds)
    clubs = Foundation.build_foundation(10, :clubs)
    hearts = Foundation.build_foundation(10, :hearts)
    spades = Foundation.build_foundation(10, :spades)

    t1 = Tableau.new [Card.get(13, :hearts), Card.get(10, :hearts)],
        [Card.get(12, :hearts)]
    t2 = Tableau.new [Card.get(13, :diamonds), Card.get(10, :diamonds)],
        [Card.get(12, :diamonds)]
    t3 = Tableau.new [Card.get(13, :clubs), Card.get(10, :clubs)],
        [Card.get(12, :clubs)]
    t4 = Tableau.new [Card.get(13, :spades), Card.get(10, :spades)],
        [Card.get(12, :spades)]

    state = {
      :diamonds_foundation => diamonds,
      :spades_foundation => spades,
      :hearts_foundation => hearts,
      :clubs_foundation => clubs,
      :tableaus => [t1, t2, t3, t4]
    }

    solver = DistanceFromSolutionSolver.new SolitaireBoard.new state

    solver.solve

    assert ! solver.solution_exists?
  end
end
