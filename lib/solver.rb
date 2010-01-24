require 'solitaire_board'
require 'sorted_queue'
require 'hash_helper'
require 'eql_helper'

# Solitaire solver
class Solver
  attr_reader :solved

  # Initializes the solver
  def initialize(initial_board)
    raise "No board provided" if initial_board.nil?

    @start_node = SolveNode.new initial_board
    @seen_boards = {}
    @to_process = SortedQueue.new
    @solved = false
    @solved_node = nil
  end

  # The board the solver started with
  def start_board
    @start_node.board.dup
  end

  # True if a solution exists, false if no solution exists for the board or the
  # board has not been solved yet
  def solution_exists?
    ! @solved_node.nil?
  end

  # Attempts to solve the board.
  def solve
    return ! @solved_node.nil? if @solved
    @solved = true

    current_node = @start_node

    solved = false

    while !solved do
      solved = process_node(current_node)

      if solved
        @solved_node = current_node
      else
        current_node = @to_process.shift!
        break if current_node.nil?
      end
    end

    solved
  end

  # Gets an array containing the turns to go from the initial board to the
  # solution.  Raises an error if no solution exists.
  #
  # If solve has not been called yet then this will call it.
  def get_solution_turns
    solve unless @solved

    raise "No solution!" if !solution_exists?

    turns = []

    current_node = @solved_node
    until(current_node.prev_node.nil?)
      turns.unshift current_node.turn
      current_node = current_node.prev_node
    end

    turns
  end

protected

  def process_node(node)
    return false if node.nil?

    board = node.board

    return true if board.solved?

    turns = board.get_turns

    turns.each do |turn|
      new_board = turn.do_turn
      unless @seen_boards[new_board]
        @seen_boards[new_board] = true
        @to_process << SolveNode.new(new_board, turn, node)
      end
    end

    false
  end

  class SolveNode
    include Comparable
    include HashHelper
    include EqlHelper

    attr_accessor :board, :turn, :prev_node

    def initialize(board, turn=nil, prev_node=nil)
      @board = board
      @turn = turn
      @prev_node = prev_node
    end

    def <=>(other)
      return 0 if eql?(other)

      comp = board.turn_count <=> other.board.turn_count
      return comp unless comp == 0

      # In theory the boards that have less hidden cards are closer to being
      # solved.  By sorting by the number of hidden cards left we'll end up
      # processing those first, hopefully getting us to the solution sooner.
      comp = board.num_hidden <=> other.board.num_hidden

      return comp unless comp == 0

      # Anything with the same turn count and number of hidden cards is
      # considered equal as far as the sorting for solving goes.  However, the
      # tree requires non-equal objects to not have a sort value of 0.  The
      # easiest thing to do is to use the hash value and then make sure that
      # they can never be the same.  It's a hack, but the best I've got for
      # now.
      my_hash = hash
      their_hash = other.hash
      if my_hash == their_hash
        their_hash += 1
      end
      my_hash <=> their_hash
    end

    def hash
      # Turn's hash includes the board's hash
      generate_hash([:@turn])
    end

    def eql?(other)
      check_equal(other, [:@board, :@turn])
    end

    def ==(other)
      eql?(other)
    end

    def to_s
      "#{board.hash} #{turn.to_s}"
    end
  end
end
