# frozen_string_literal: true

##
# Board for mastermind
class Board
  attr_reader :last_guess_code

  def initialize(rounds)
    @rounds = rounds
    @guess_code_board = Array.new(@rounds) { Array.new(4, '_') }
    @feedback_board = Array.new(@rounds) { Array.new(2, '_') }
  end

  def to_s
    board = "--------------------------------------------\n"
    board += "|       Code guess     | Feedback( ✓ | ✗ ) | \n"
    board += "--------------------------------------------\n"
    @rounds.times do |index|
      round_number = index < 9 ? "0#{index + 1}" : index + 1
      board += "Round ##{round_number} | #{@guess_code_board[index].join('  ')} | "
      board += "     #{@feedback_board[index].join('     ')}\n"
    end
    board += "--------------------------------------------\n"
    board
  end

  def update_guess_code(guess_code, round)
    @last_guess_code = guess_code
    @guess_code_board[round] = @last_guess_code.split('')
  end

  def update_feedback_code(feedback, round)
    @feedback_board[round] = feedback
  end
end
