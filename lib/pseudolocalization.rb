require "pseudolocalization/version"

module Pseudolocalization
  module I18n
    class Backend
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
        result = @old_backend.translate(locale, key, options)

        return result unless result.is_a?(String)

        # replace html entities, we don't care
        result = result.gsub(/&[a-z]+;/, ' ')

        # double all vowels in an attempt to increase words length
        result = result.gsub(/[aeiouy]/) { |c| c * 2 }

        # replace chars with utf8 lookalike
        result.gsub(/[a-z]/, LEET)
      end
    end
  end
end
