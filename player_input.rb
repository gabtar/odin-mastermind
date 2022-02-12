# frozen_string_literal: true

##
# Mixin for generic validation for input strings
module Validation
  def validate_input(regex, input_message, error_message)
    input = ''
    loop do
      print input_message
      input = gets.chomp
      break if input.match?(regex)

      puts error_message
    end
    input
  end
end

##
# Player interface for entering/validating input
class PlayerInput
  attr_reader :secret_code

  include Validation

  VALIDATIONS_RULES = { default: '^[1-6]{4}$',
                        allow_duplicates: '^(?:([1-6])(?!.*\1)){4}$',
                        feedback_input: '^[0-4]$' }.freeze

  def provide_secret_code(allow_duplicates)
    regex = allow_duplicates ? VALIDATIONS_RULES[:default] : VALIDATIONS_RULES[:allow_duplicates]
    message = '4 numbers from 1-6'
    message = allow_duplicates ? message : "#{message}\nNo duplicates numbers allowed."
    @secret_code = validate_input(regex, 'Enter secret code: ', message)
  end

  def guess_code
    validate_input(VALIDATIONS_RULES[:default], 'Enter your guess: ', 'Invalid. 4 digits from 1-6')
  end

  def feedback_code
    exact = validate_input(VALIDATIONS_RULES[:feedback_input],
                           'Enter the number of exacts: ',
                           'Invalid input. 1-4 allowed')
    wrong = validate_input(VALIDATIONS_RULES[:feedback_input],
                           'Enter the number of wrong position: ',
                           'Invalid input. 1-4 allowed')
    [exact.to_i, wrong.to_i]
  end
end
