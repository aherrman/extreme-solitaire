require 'solver'
require 'solitaire_board'

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

puts "Solving for board:"
puts board.to_display_string

solver = Solver.new board
solver.solve { |turn_count, queue_size, skipped|
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
