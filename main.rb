#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'player_input'
require_relative 'computer'
require_relative 'board'

##
# Interface for playing games
class Game
  WELCOME_MESSAGE = <<~WELCOME_SCREEN
    ---------------------------------------------------------------------
    Mastermind!!!
    Two player game. You can play either as codemaker or codebreaker
    Rules:
    ---------------------------------------------------------------------
    - The codemaker defines a secret code of 4 digits
    - Each round the codebreaker chooses a candidate guess code
    - The codemaker reports a feedback for each guess code as follows:
      Exact position (✓): 1-4 (if a number of the guess code is on exact position as in the secret code)
      Wrong position (✗): 1-4 (if a number of the guess code is on present in the secret code but on a wrong position)
    - The game continues until the codebreaker guess the secret code or out of turns
    Default rules:
      Duplicated numbers in code: Not allowed(easy way).
      Number of Rounds to guess the secret code: 12.
  WELCOME_SCREEN

  MENU = <<~MAIN_MENU
    --------------------------------
    MASTERMIND
    --------------------------------
    1> Play as Codebreaker
    2> Play as Codemaker
    3> Change rules
    4> Exit
    --------------------------------
    Select option:
  MAIN_MENU

  include Validation

  def initialize
    # Default game rules
    @rules = { rounds: 12, allow_duplicates: false }
  end

  def start_game
    system 'clear'
    puts WELCOME_MESSAGE
    loop do
      puts MENU
      case gets.chomp
      when '1'
        new_game('codebreaker')
      when '2'
        new_game('codemaker')
      when '3'
        change_rules
        system 'clear'
      when '4'
        exit
      else
        # Invalid option
        system 'clear'
      end
    end
  end

  private

  def new_game(type)
    setup_game(type)
    @rules[:rounds].times do
      break if play_round

      @current_round += 1
    end
    display_winner
  end

  def setup_game(type)
    @board = Board.new(@rules[:rounds])
    case type
    when 'codebreaker'
      @codemaker = CpuMaker.new(@board)
      @codebreaker = PlayerInput.new
    when 'codemaker'
      @codemaker = PlayerInput.new
      @codebreaker = CpuBreaker.new
    end
    @current_round = 0
    @codemaker.provide_secret_code(@rules[:allow_duplicates])
  end

  def play_round
    code_guess = @codebreaker.guess_code
    @board.update_guess_code(code_guess, @current_round)
    system 'clear'

    puts @board if @codemaker.instance_of?(PlayerInput)

    feedback = @codemaker.feedback_code
    @codebreaker.last_feedback = feedback if @codebreaker.instance_of?(CpuBreaker)
    @board.update_feedback_code(feedback, @current_round)

    puts @board if @codebreaker.instance_of?(PlayerInput)
    # Returns true if the Codebreaker guess the secret code
    @winner = feedback[0] == 4
  end

  def display_winner
    message = @winner ? 'Codebreaker Won!!!!' : 'Codemaker Won!!!!'
    message += "Secret code: #{@codemaker.secret_code}"
    puts message
  end

  def change_rules
    puts "--------------------------------\n"
    puts "Current rules:\nRounds: #{@rules[:rounds]}\nAllow duplicates: #{@rules[:allow_duplicates]}"
    rounds = validate_input('^([8-9]|1[0-2])$', 'Enter number of rounds(8-12): ', 'Invalid number of rounds')
    allow_duplicates = validate_input('^[y,n]$', 'Allow duplicates(y/n): ', 'Invalid answer')
    @rules[:rounds] = rounds.to_i
    @rules[:allow_duplicates] = allow_duplicates == 'y'
  end
end

game = Game.new
game.start_game
