require_relative "pseudolocalization/version"
require_relative "pseudolocalization/pseudolocalizer"

module Pseudolocalization
  module I18n
    class Backend
      attr_reader :original_backend

      def initialize(original_backend)
        @original_backend = original_backend
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
        ::Pseudolocalization::I18n::Pseudolocalizer.pseudolocalize(original_backend.translate(locale, key, options))
      end
    end
  end
end
