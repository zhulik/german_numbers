# GermanNumbers

German numbers is a ruby gem for converting numbers into German strings and vise-versa.
It supports numbers up to 999 999 999 999. Also it can handle malformed and invalid strings. See
examples below.

## Installation

`gem install german_numbers`

or

`gem 'german_numbers'` in your Gemfile.

## Usage

```ruby
require 'german_numbers'

GermanNumbers.stringify(213_431_983_111) # => "zweihundertdreizehn Milliarden vierhunderteinunddreißig Millionen neunhundertdreiundachtzigtausendeinhundertelf"

GermanNumbers.parse("zweihundertdreizehn Milliarden vierhunderteinunddreißig Millionen neunhundertdreiundachtzigtausendeinhundertelf") # => 213_431_983_111
GermanNumbers.parse("invalid") # => GermanNumbers::Parser::ParsingError: invalid is not a valid German number

GermanNumbers.valid?("zweihundertdreizehn Milliarden vierhunderteinunddreißig Millionen neunhundertdreiundachtzigtausendeinhundertelf") # => true
GermanNumbers.valid?("invalid") # => false

```

## Contributing

You know=)