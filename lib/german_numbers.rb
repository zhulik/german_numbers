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
  end
end

require 'german_numbers/stringifier'
require 'german_numbers/parser/error'
require 'german_numbers/parser/machine'
require 'german_numbers/parser/parser'
