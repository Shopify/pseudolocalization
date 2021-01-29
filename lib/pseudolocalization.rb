require_relative "pseudolocalization/version"
require_relative "pseudolocalization/pseudolocalizer"

module Pseudolocalization
  module I18n
    class Backend
      attr_reader :original_backend
      attr_accessor :ignores

      def initialize(original_backend)
        @original_backend = original_backend
        @ignores = []
        yield self if block_given?
      end

      def method_missing(name, *args, &block)
        if respond_to_missing?(name)
          original_backend.public_send(name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        original_backend.respond_to?(name) || super
      end

      def translate(locale, key, options)
        return original_backend.translate(locale, key, options) if key_ignored?(key)

        ::Pseudolocalization::I18n::Pseudolocalizer.pseudolocalize(original_backend.translate(locale, key, options))
      end

      private

      def key_ignored?(key)
        return false unless ignores

        ignores.any? do |ignore|
          case ignore
          when Regexp
            key.to_s.match(ignore)
          when String
            File.fnmatch(ignore, key.to_s)
          else
            Rails.logger.tagged('Pseudolocalization I18n').error 'Ignore type unsupported. Expects an array of (mixed) Regexp or Strings.'
            return false
          end
        end
      end
    end
  end
end
