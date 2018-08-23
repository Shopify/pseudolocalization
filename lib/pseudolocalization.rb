require_relative "pseudolocalization/version"
require_relative "pseudolocalization/pseudolocalizer"

module Pseudolocalization
  module I18n
    class Backend
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
        ::Pseudolocalization::I18n::Pseudolocalizer.pseudolocalize(@old_backend.translate(locale, key, options))
      end
    end
  end
end
