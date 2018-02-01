require "test_helper"

class PseudolocalizationTest < Minitest::Test
  class DummyBackend
    def translate(_locale, string, _options)
      string
    end
  end

  def setup
    @backend = Pseudolocalization::I18n::Backend.new(DummyBackend.new)
  end

  def test_that_it_has_a_version_number
    refute_nil ::Pseudolocalization::VERSION
  end

  def test_it_pseudolocalizes
    assert_equal 'Hεεll00, ω00rld!', @backend.translate(:en, 'Hello, world!', {})
  end
end
