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

  def test_it_works_with_html_entities
    assert_equal 'Plεεααsεε, <a href="#test">ͼl11ͼϏ hεεrεε</a>!', @backend.translate(:en, 'Please, <a href="#test">click here</a>!', {})
  end
end
