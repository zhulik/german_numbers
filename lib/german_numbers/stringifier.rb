# typed: strict
# frozen_string_literal: true

module GermanNumbers
  class Stringifier
    extend T::Sig

    SMALL_KEYWORDS = T.let(%w(hundert tausend), T::Array[String])
    BIG_KEYWORDS = T.let(%w(Million Milliarde), T::Array[String])

    sig { params(number: Integer).returns(String) }
    def words(number)
      raise ArgumentError if number > 999_999_999_999 || number.negative?
      return postprocess(DIGITS[number]) unless DIGITS[number].nil?

      number = number.to_s.rjust(12, '0')

      billions, millions, thousands, number = number.reverse.scan(/.{1,3}/).map do |part|
        part = T.cast(part, String)
        part.reverse.to_i
      end.reverse

      postprocess(process(T.must(billions), T.must(millions), T.must(thousands), T.must(number)))
    end

    private

    sig { params(billions: Integer, millions: Integer, thousands: Integer, number: Integer).returns(String) }
    def process(billions, millions, thousands, number)
      result = under_thousand(number)
      result = "#{under_thousand(thousands)}#{DIGITS[1000]}#{result}" unless thousands.zero?
      unless millions.zero?
        n = under_thousand(millions)
        result = "#{n == 'ein' ? 'eine' : n} #{decline(millions, DIGITS[1_000_000])} #{result}"
      end
      unless billions.zero?
        n = under_thousand(billions)
        result = "#{n == 'ein' ? 'eine' : n} #{decline(billions, DIGITS[1_000_000_000])} #{result}"
      end
      result
    end

    sig { params(result: String).returns(String) }
    def postprocess(result)
      result += 's' if result.end_with?('ein')
      result = 'ein' + result if SMALL_KEYWORDS.include?(result)
      result = 'eine ' + result if BIG_KEYWORDS.include?(result)
      result.strip
    end

    sig { params(number: Integer).returns(String) }
    def under_thousand(number)
      digits = number.to_s.split('').reverse.map(&:to_i)
      result = under_hundred(digits.first(2))
      result = DIGITS[digits.last] + DIGITS[100] + result if digits.count > 2
      result
    end

    sig { params(digits: T::Array[Integer]).returns(String) }
    def under_hundred(digits)
      return '' if digits.all?(&:zero?)

      n = DIGITS["#{digits[1]}#{digits[0]}".to_i]
      return n unless n.nil?

      DIGITS[digits[0]] + 'und' + DIGITS[(T.must(digits[1]) * 10)]
    end

    sig { params(count: Integer, number: String).returns(String) }
    def decline(count, number)
      return number if count == 1
      return number + 'n' if number.end_with?('e')

      number + 'en'
    end
  end
end
