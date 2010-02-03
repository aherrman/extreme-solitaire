require 'distance_from_solution_solver'
require 'turn_count_solver'
require 'solitaire_board'
require 'optparse'

class Main
  CLEAR_STR = "\e[2J\e[f"
  def print_help(opts)
    puts opts
    exit
  end

  def setup_board(options)
    shuffle_count = options[:shuffles]

    deck = StackOfCards.default_stack

    unless options[:rand_seed].nil?
      srand options[:rand_seed]
    end

    deck.shuffle!(shuffle_count)
    SolitaireBoard.build_from_deck deck
  end

  def setup_turn_count_solver(board, options)
    last_turn_count = 0
    solver = TurnCountSolver.new board
    clear = options[:clear]

    solver.on_progress do |count, processed, queued, skipped|
      if count > last_turn_count
        print clear ? "\r" : "\n"
        print "On turn #{count} - p: #{processed} q: #{queued} s: #{skipped}"
        last_turn_count = count
      end
    end

    solver
  end

  def setup_distance_solver(board, options)
    last_time = Time.at(0)
    solver = DistanceFromSolutionSolver.new board
    clear = options[:clear]

    solver.on_progress do |count, processed, queued, skipped|
      now = Time.now
      if now > (last_time + 1)
        print clear ? "\r" : "\n"
        print "On turn #{count} - p: #{processed} q: #{queued} s: #{skipped}"
        last_time = now
      end
    end

    solver
  end

  def setup_solver(board, options)
    if options[:solver] == :turn
      setup_turn_count_solver board, options
    else
      setup_distance_solver board, options
    end
  end

  def print_solution(solver, options)
    interactive = options[:interactive]
    clear = options[:clear]

    print "\n"

    if ! solver.solution_exists?
      puts "No solution exists\n"
    else
      puts "Solution exists!"

      turns = solver.get_solution_turns
      num_turns = turns[-1].board.turn_count

      turns.each do |turn|
        if interactive
          STDIN.gets
          print Main::CLEAR_STR if clear
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
  end

  def load_options
    options = {
      :interactive => false,
      :clear => false,
      :shuffles => 0,
      :solver => :distance,
      :rand_seed => nil,
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

      opts.on('-r', '--random_seed SEED', Integer,
          'The random seed to use.  If not provided then the ruby ' \
          'default is used.') { |s|
        options[:rand_seed] = s
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

    options
  end

  def run
    options = load_options
    board = setup_board(options)

    clear = options[:clear]

    print Main::CLEAR_STR if clear

    puts "Solving for board:"
    puts board.to_display_string

    solver = setup_solver(board, options)

    max_steps = options[:max_steps]
    solver.solve(max_steps)

    print_solution(solver, options)
  end
end

main = Main.new
main.run
