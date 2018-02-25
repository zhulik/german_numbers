# frozen_string_literal: true

require 'yaml'

require 'german_numbers/version'
require 'german_numbers/state_machine'

module GermanNumbers
  DIGITS = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'data', 'de.yml'))['de']

  class << self
    def stringify(number)
      GermanNumbers::Stringifier.new.words(number)
    end

    def parse(string)
      GermanNumbers::Parser::Parser.new.parse(string)
    end

    def valid?(string)
      GermanNumbers::Parser::Parser.new.parse(string)
      true
    rescue GermanNumbers::Parser::ParsingError
      false
    end
  end
end

require 'german_numbers/stringifier'
require 'german_numbers/parser/small_number_parser'
require 'german_numbers/parser/stack_machine'
require 'german_numbers/parser/parser'
