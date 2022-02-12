# frozen_string_literal: true

##
# Mixin for report feedback of guess code used in both
# CpuMaker and CpuBreaker classes
module Feedback
  # Determines the exact and wrong position numbers
  # guess_code and secret_code are strings
  # Returns an array containing the exact matches on first index
  # and matches in wrong position in the second index
  def feedback_code(guess_code, secret_code)
    exact = 0
    wrong = 0
    guess_code = guess_code.split('')
    secret_code = secret_code.split('')

    guess_code.each_with_index do |number, index|
      next unless number == secret_code[index]

      exact += 1
      secret_code[index] = nil
      guess_code[index] = nil
    end

    # Check if the rest numbers are in wrong position or not
    # Also avoid adding a number in wrong counter if the number was
    # already added in exact position.
    guess_code.each do |number|
      if !number.nil? && secret_code.include?(number)
        wrong += 1
        secret_code[secret_code.index(number)] = nil
      end
    end
    [exact, wrong]
  end
end

##
# AI for computer Codemaker
class CpuMaker
  include Feedback

  attr_reader :secret_code

  def initialize(board)
    # Needs the board object to access last guess code for feedback
    @board = board
  end

  def provide_secret_code(allow_duplicates)
    secret_code = []
    loop do
      number = rand(1..6)
      next if secret_code.include?(number) && !allow_duplicates

      secret_code << number
      break if secret_code.length == 4
    end
    @secret_code = secret_code.join('')
    secret_code
  end

  def feedback_code
    super(@board.last_guess_code, @secret_code)
  end
end

##
# AI for computer Codebreaker
class CpuBreaker
  include Feedback

  attr_accessor :last_feedback

  def initialize
    @posible_code = (1111..6666).to_a.reject! { |code| code.to_s.match?(/[0,7,8,9]/) }
    @first_guess = true
  end

  # Feedback is an array of [exact, wrong] matches for last code
  def guess_code
    # Using Swaszek (1999-2000) strategy, as suggested in an answer here:
    # https://puzzling.stackexchange.com/questions/546/clever-ways-to-solve-mastermind
    if @first_guess
      @first_guess = false
      @last_code = '1122'
    else
      @posible_code.select! do |code|
        feedback_code(code.to_s, @last_code) == @last_feedback
      end
      @last_code = @posible_code[0].to_s
    end
    @last_code
  end
end
