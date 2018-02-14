require "pseudolocalization/version"

module Pseudolocalization
  module I18n
    class Backend
      BRACKET_START = '<'
      BRACKET_END = '>'

      VOWELS = %w(a e i o u y)

      LEET = {
        'a' => 'α',
        'b' => 'β',
        'c' => 'ͼ',
        'd' => 'd',
        'e' => 'ε',
        'f' => 'ϝ',
        'g' => 'g',
        'h' => 'h',
        'i' => '1',
        'j' => 'ϳ',
        'k' => 'Ϗ',
        'l' => 'l',
        'm' => 'ϻ',
        'n' => 'ͷ',
        'o' => '0',
        'p' => 'ρ',
        'q' => 'q',
        'r' => 'r',
        's' => 's',
        't' => 'ϯ',
        'u' => 'u',
        'v' => 'v',
        'w' => 'ω',
        'x' => 'x',
        'y' => 'ϒ',
        'z' => 'z',
      }

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

        outside_brackets = true

        string.chars.map do |char|
          if char == BRACKET_START
            outside_brackets = false
            char
          elsif char == BRACKET_END
            outside_brackets = true
            char
          elsif outside_brackets && LEET.key?(char)
            ret = LEET[char]
            ret = ret * 2 if VOWELS.include?(char)
            ret
          else
            char
          end
        end.join
      end
    end
  end
end
