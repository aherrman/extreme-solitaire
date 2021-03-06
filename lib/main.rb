require 'distance_from_solution_solver'
require 'turn_count_solver'
require 'solitaire_board'
require 'optparse'
require 'board_json'

class Main
  CLEAR_STR = "\e[2J\e[f"
  def print_help
    puts @optparse
    exit
  end

  def setup_board(options)
    file = options[:initial_board]

    return setup_board_from_deck(options) if file.nil?

    setup_board_from_file(options)
  end

  def setup_board_from_deck(options)
    shuffle_count = options[:shuffles]

    deck = StackOfCards.default_stack

    unless options[:rand_seed].nil?
      srand options[:rand_seed]
    end

    deck.shuffle!(shuffle_count)
    SolitaireBoard.build_from_deck deck
  end

  def setup_board_from_file(options)
    file = options[:initial_board]

    begin
      JSON.parse IO.read(file)
    rescue JSON::ParserError => e
      puts "Error parsing board file: #{e.message}"
      print_help
    rescue Exception => e
      puts "Error reading board: #{e.message}"
      print_help
    end
  end

  def setup_turn_count_solver(board, options)
    last_turn_count = 0
    last_time = Time.at(0)
    dtime = options[:progress_time]
    solver = TurnCountSolver.new board
    clear = options[:clear]
    max_steps = options[:max_steps]

    solver.on_process do |count, processed, queued, skipped|
      now = Time.now
      if count > last_turn_count || now > (last_time + dtime)
        print clear ? "\r" : "\n"
        print "On turn #{count} - p: #{processed} q: #{queued} s: #{skipped}"
        last_turn_count = count
        last_time = now
      end
      max_steps.nil? || processed < max_steps
    end

    solver
  end

  def setup_distance_solver(board, options)
    last_time = Time.at(0)
    solver = DistanceFromSolutionSolver.new board
    clear = options[:clear]
    dtime = options[:progress_time]
    max_steps = options[:max_steps]

    solver.on_process do |count, processed, queued, skipped|
      now = Time.now
      if now > (last_time + dtime)
        print clear ? "\r" : "\n"
        print "On turn #{count} - p: #{processed} q: #{queued} s: #{skipped}"
        last_time = now
      end
      max_steps.nil? || processed < max_steps
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
      :progress_time => 1,
      :initial_board => nil,
      :max_steps => nil
    }

    @optparse = OptionParser.new do |opts|
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

      opts.on('-t', '--progress_time TIME', Float,
          'The max time in seconds between progress displays') { |t|
        options[:progress_time] = t
      }

      opts.on('-b', '--board BOARD', 'The initial board to use instead of shuffling the deck') { |b|
        options[:initial_board] = b
      }

      opts.on('-h', '--help', 'Display usage') {
        print_help
      }
    end

    begin
      @optparse.parse ARGV
    rescue RuntimeError
      print_help
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

    solver.solve

    print_solution(solver, options)
  end
end

main = Main.new
main.run
