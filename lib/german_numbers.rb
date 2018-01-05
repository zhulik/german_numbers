# frozen_string_literal: true

require 'german_numbers/version'
require 'german_numbers/to_words'

module GermanNumbers
  DIGITS = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'data', 'de.yml'))['de']

  class << self
    def words(ws)
      ToWords.new.words(ws)
    end
  end
end
