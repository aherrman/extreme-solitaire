require 'distance_from_solution_solver'
require 'turn_count_solver'
require 'solitaire_board'
require 'optparse'

def print_help(opts)
  puts opts
  exit
end

options = {
  :interactive => false,
  :clear => false,
  :shuffles => 0,
  :solver => :distance,
  :max_steps => nil
}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"

  opts.on('-i', '--interactive', 'Display the solution interactively') {
    options[:interactive] = true
  }

  opts.on('-c', '--clear',
      'Clears the console between each turn display when in interactive mode') {
    options[:clear] = true
  }

  opts.on('-s', '--shuffles SHUFFLES', Integer,
      'Number of times to shuffle the deck') { |s|
    options[:shuffles] = s
  }

  opts.on('-m', '--max_steps MAX_STEPS', Integer,
      'Maximum number of steps to run') { |m|
    options[:max_steps] = m
  }

  opts.on('--solver SOLVER', [:distance, :turn],
      'The solver to use.  Either distance or turn') { |s|
    options[:solver] = s
  }

  opts.on('-h', '--help', 'Display usage') {
    print_help opts
  }
end

begin
  optparse.parse ARGV
rescue RuntimeError
  print_help optparse
end

interactive = options[:interactive]
clear = options[:clear]
shuffle_count = options[:shuffles]
max_steps = options[:max_steps]

deck = StackOfCards.default_stack

deck.shuffle!(shuffle_count)
board = SolitaireBoard.build_from_deck deck

puts "Solving for board:"
puts board.to_display_string

if options[:solver] == :turn
  solver = TurnCountSolver.new board
else
  solver = DistanceFromSolutionSolver.new board
end


solver.solve(max_steps)

if ! solver.solution_exists?
  puts "No solution exists\n"
else
  puts "Solution exists!"

  turns = solver.get_solution_turns
  num_turns = turns[-1].board.turn_count

  turns.each do |turn|
    if interactive
      STDIN.gets
      print "\e[2J\e[f" if clear
    end
    puts "Turn ##{turn.board.turn_count} of #{num_turns}"
    puts turn.board.to_display_string
    puts turn.to_s
    puts '----------------------------------------------------------------------'
  end

  puts "Solved in #{num_turns}"
end

puts "Processed #{solver.processed} nodes"
puts "Queued #{solver.queued} nodes"
puts "Skipped #{solver.skipped} nodes"
