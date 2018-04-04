require "pseudolocalization/version"

module Pseudolocalization
  module I18n
    class Backend
      ESCAPED_CHARS = [
        ['<', '>'],
        ['{{', '}}'],
      ]

      ESCAPED_PATTERNS = ESCAPED_CHARS.map do |(a, b)|
        "#{a}.*?#{b}"
      end

      ESCAPED_REGEX = Regexp.new("(#{ESCAPED_PATTERNS.join('|')})")

      VOWELS = %w(a e i o u y A E I O U Y)

      LETTERS = {
        'a' => 'α',
        'b' => 'ḅ',
        'c' => 'ͼ',
        'd' => 'ḍ',
        'e' => 'ḛ',
        'f' => 'ϝ',
        'g' => 'ḡ',
        'h' => 'ḥ',
        'i' => 'ḭ',
        'j' => 'ĵ',
        'k' => 'ḳ',
        'l' => 'ḽ',
        'm' => 'ṃ',
        'n' => 'ṇ',
        'o' => 'ṓ',
        'p' => 'ṗ',
        'q' => 'ʠ',
        'r' => 'ṛ',
        's' => 'ṡ',
        't' => 'ṭ',
        'u' => 'ṵ',
        'v' => 'ṽ',
        'w' => 'ẁ',
        'x' => 'ẋ',
        'y' => 'ẏ',
        'z' => 'ẓ',
        'A' => 'Ḁ',
        'B' => 'Ḃ',
        'C' => 'Ḉ',
        'D' => 'Ḍ',
        'E' => 'Ḛ',
        'F' => 'Ḟ',
        'G' => 'Ḡ',
        'H' => 'Ḥ',
        'I' => 'Ḭ',
        'J' => 'Ĵ',
        'K' => 'Ḱ',
        'L' => 'Ḻ',
        'M' => 'Ṁ',
        'N' => 'Ṅ',
        'O' => 'Ṏ',
        'P' => 'Ṕ',
        'Q' => 'Ǫ',
        'R' => 'Ṛ',
        'S' => 'Ṣ',
        'T' => 'Ṫ',
        'U' => 'Ṳ',
        'V' => 'Ṿ',
        'W' => 'Ŵ',
        'X' => 'Ẋ',
        'Y' => 'Ŷ',
        'Z' => 'Ż',
      }.freeze

      def initialize(old_backend)
        @old_backend = old_backend
      end

      def method_missing(name, *args, &block)
        if respond_to_missing?(name)
          @old_backend.public_send(name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        @old_backend.respond_to?(name) || super
      end

      def translate(locale, key, options)
        translate_object(@old_backend.translate(locale, key, options))
      end

      def translate_object(object)
        if object.is_a?(Hash)
          object.transform_values { |value| translate_object(value) }
        elsif object.is_a?(Array)
          object.map { |value| translate_object(value) }
        elsif object.is_a?(String)
          translate_string(object)
        else
          object
        end
      end

      def translate_string(string)
        string = string.gsub(/&[a-z]+;/, ' ')

        string.split(ESCAPED_REGEX).map do |part|
          if part =~ ESCAPED_REGEX
            part
          else
            part.chars.map do |char|
              if LETTERS.key?(char)
                value = LETTERS[char]
                value = value * 2 if VOWELS.include?(char)
                value
              else
                char
              end
            end.join
          end
        end.join
      end
    end
  end
end
