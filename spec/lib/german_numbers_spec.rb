# typed: false
# frozen_string_literal: true

describe GermanNumbers do
  EXAMPLES = {
    0 => 'null',
    1 => 'eins',
    4 => 'vier',
    11 => 'elf',
    12 => 'zwölf',
    17 => 'siebzehn',
    30 => 'dreißig',
    41 => 'einundvierzig',
    99 => 'neunundneunzig',
    100 => 'einhundert',
    101 => 'einhunderteins',
    111 => 'einhundertelf',
    112 => 'einhundertzwölf',
    117 => 'einhundertsiebzehn',
    133 => 'einhundertdreiunddreißig',
    300 => 'dreihundert',
    843 => 'achthundertdreiundvierzig',
    801 => 'achthunderteins',
    810 => 'achthundertzehn',
    999 => 'neunhundertneunundneunzig',
    1000 => 'eintausend',
    2010 => 'zweitausendzehn',
    2100 => 'zweitausendeinhundert',
    2300 => 'zweitausenddreihundert',
    2213 => 'zweitausendzweihundertdreizehn',
    2254 => 'zweitausendzweihundertvierundfünfzig', # my eyes!
    10_000 => 'zehntausend',
    10_100 => 'zehntausendeinhundert',
    12_100 => 'zwölftausendeinhundert',
    20_100 => 'zwanzigtausendeinhundert',
    20_200 => 'zwanzigtausendzweihundert',
    503_000 => 'fünfhundertdreitausend',
    503_100 => 'fünfhundertdreitausendeinhundert',
    543_481 => 'fünfhundertdreiundvierzigtausendvierhunderteinundachtzig', # my fucking eyes!,
    727_727 => 'siebenhundertsiebenundzwanzigtausendsiebenhundertsiebenundzwanzig', # fuck!

    1_000_000 => 'eine Million',
    1_000_001 => 'eine Million eins',
    2_000_000 => 'zwei Millionen',
    2_000_006 => 'zwei Millionen sechs',
    12_000_006 => 'zwölf Millionen sechs',
    727_727_727 => 'siebenhundertsiebenundzwanzig Millionen siebenhundertsiebenundzwanzigtausendsiebenhundertsiebenundzwanzig', # AHAHAHAHA
    1_000_000_000 => 'eine Milliarde',
    2_000_000_000 => 'zwei Milliarden',
    2_001_000_000 => 'zwei Milliarden eine Million',
    2_002_000_000 => 'zwei Milliarden zwei Millionen',
    2_002_123_000 => 'zwei Milliarden zwei Millionen einhundertdreiundzwanzigtausend',
    2_002_123_123 => 'zwei Milliarden zwei Millionen einhundertdreiundzwanzigtausendeinhundertdreiundzwanzig',
    213_431_983_111 => 'zweihundertdreizehn Milliarden vierhunderteinunddreißig Millionen neunhundertdreiundachtzigtausendeinhundertelf'
  }.freeze

  describe '.stringify' do
    EXAMPLES.each do |number, words|
      it "for #{number} it returns #{words}" do
        expect(described_class.stringify(number)).to eq(words)
      end
    end
  end

  describe '.parse' do
    EXAMPLES.each do |number, words|
      # next unless number < 2_002_000_000
      it "for #{words} it returns #{number}" do
        expect(described_class.parse(words)).to eq(number)
      end
    end

    ['ein', 'sech', 'sieb', 'undeinundvierzig', 'neunhundertachthunderteins', 'nullhundert', 'zehnhundert',
     'dreißighundert', 'wrong', 'errorhundert', '123', 'einshundert', 'einstausend', 'zwölfhundert',
     'einstausendeinstausend', 'und', 'undneunzig', 'einhundertundneunzig', 'nulltausend', 'siebenzehn', 'einzehn',
     'einszehn', 'sechszehn', 'zweizehn', 'hundert', '', 'zwei Million', 'zwei Billion', 'eine Millionen',
     'eine Milliarden', 'eintausend Millionen', 'null Million', 'null Millionen', 'null Milliarde', 'null Milliarden',
     'ein Millionen', 'eins Millionen', 'ein Milliarde', 'ein Milliarden', 'eine Million eine Million',
     'eine Milliarde eine Milliarde', 'Million', 'Milliarde', 'Millionen', 'Milliarden'].each do |words|
      it "for '#{words}' it raises error" do
        expect { described_class.parse(words) }.to raise_error(GermanNumbers::Parser::ParsingError)
      end
    end

    xit 'vise-versa' do
      require 'ruby-prof'
      result = RubyProf.profile do
        (0..25_000).each do |num|
          expect(described_class.parse(described_class.stringify(num))).to eq(num)
        end
      end
      printer = RubyProf::GraphPrinter.new(result)
      printer.print(STDOUT, {})
    end
  end

  describe 'valid?' do
    context 'when valid number is passed' do
      it 'returns true' do
        expect(described_class.valid?('zwei Millionen sechs')).to be_truthy
      end
    end

    context 'when invalid number is passed' do
      it 'returns false' do
        expect(described_class.valid?('invalid')).to be_falsey
      end
    end
  end
end
