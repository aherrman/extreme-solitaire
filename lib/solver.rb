require 'solitaire_board'
require 'sorted_queue'
require 'hash_helper'
require 'eql_helper'

# Solitaire solver
class Solver
  # True once the solver has run
  attr_reader :solved

  # The number of nodes that were ever queued
  attr_reader :queued

  # The number of nodes that were skipped because the board had already been
  # seen
  attr_reader :skipped

  # The number of nodes that were processed
  attr_reader :processed

  # Initializes the solver
  def initialize(initial_board, &board_compare)
    raise "No board provided" if initial_board.nil?

    @start_node = SolveNode.new(initial_board, nil, nil, &board_compare)
    @seen_boards = {}
    @to_process = SortedQueue.new
    @solved = false
    @solved_node = nil
    @skipped = 0
    @queued = 0
    @processed = 0
    @board_compare = board_compare
    @progress = nil
  end

  # Sets the block to call to report progress.  This callback is called every
  # time a node is going to be processed, so generally it shouldn't do anything
  # expensive.
  #
  # The callback is passed the turn count of the current board, the number of
  # nodes that have been processed, the size of the to_process queue, and the
  # number of nodes that were skipped.
  def on_progress(&progress)
    @progress = progress
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
  # A maximum number of nodes to process may be passed in.  The solving will
  # stop once that number of nodes have been processed.  If not provided then
  # the solver will run to completion.
  #
  # If the max count is reached before finishing then the solver will continue
  # where it left off if solve is called again.
  def solve(max_count=nil)
    return ! @solved_node.nil? if @solved

    current_node = @start_node

    solved = false

    while !solved do
      unless max_count.nil?
        return false if max_count <= 0
        max_count -= 1
      end

      unless @progress.nil?
        @progress.call(current_node.board.turn_count, @processed,
                      @to_process.size, @skipped)
      end

      solved = process_node(current_node)

      if solved
        @solved_node = current_node
      else
        current_node = @to_process.shift!
        break if current_node.nil?
      end
    end

    @solved = true
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
    @processed += 1

    board = node.board

    return true if board.solved?

    turns = board.get_turns

    turns.each do |turn|
      new_board = turn.do_turn
      unless @seen_boards[new_board]
        @seen_boards[new_board] = true
        @to_process << SolveNode.new(new_board, turn, node, &@board_compare)
        @queued += 1
      else
        @skipped += 1
      end
    end

    false
  end

  class SolveNode
    include Comparable
    include HashHelper
    include EqlHelper

    attr_accessor :board, :turn, :prev_node

    def initialize(board, turn, prev_node, &board_compare)
      @board_compare = board_compare
      @board = board
      @turn = turn
      @prev_node = prev_node
    end

    def <=>(other)
      @board_compare.call(@board, other.board)
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
