# typed: strict
# frozen_string_literal: true

require 'yaml'
require 'sorbet-runtime'

require 'german_numbers/version'
require 'german_numbers/state_machine'

module GermanNumbers
  DIGITS = T.let(YAML.load_file(File.join(File.dirname(__FILE__), '..', 'data', 'de.yml'))['de'],
                 T::Hash[Integer, String])

  class << self
    extend T::Sig

    sig { params(number: Integer).returns(String) }
    def stringify(number)
      GermanNumbers::Stringifier.new.words(number)
    end

    sig { params(string: String).returns(Integer) }
    def parse(string)
      GermanNumbers::Parser::Parser.new.parse(string)
    end

    sig { params(string: String).returns(T::Boolean) }
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
