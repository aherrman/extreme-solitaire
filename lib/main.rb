require 'breadth_first_solver'
require 'solitaire_board'

def read_int_arg(arg, default=0)
  value = arg
  if value.nil?
    value = default
  else
    value = Integer(value)
  end
end

deck = StackOfCards.default_stack

shuffle_count = read_int_arg ARGV[0]
max_count = read_int_arg ARGV[1]

deck.shuffle!(shuffle_count)
board = SolitaireBoard.build_from_deck deck

puts "Solving for board:"
puts board.to_display_string

solver = BreadthFirstSolver.new board
solver.solve(max_count) { |turn_count, queue_size, skipped|
  puts "Checking #{turn_count} - #{solver.processed} / #{queue_size} / #{skipped}"
}

if ! solver.solution_exists?
  puts "No solution exists\n"
  exit
end

puts "Solution exists!"

turns = solver.get_solution_turns

turns.each do |turn|
  puts turn.board.to_display_string
  puts turn.to_s
  puts '----------------------------------------------------------------------'
end

puts "Processed #{solver.processed} nodes"
puts "Queued #{solver.queued} nodes"
puts "Skipped #{solver.skipped} nodes"
