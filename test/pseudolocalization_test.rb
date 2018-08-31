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
    assert_equal 'Ḥḛḛḽḽṓṓ, ẁṓṓṛḽḍ!', @backend.translate(:en, 'Hello, world!', {})
  end

  def test_it_works_with_html_entities
    assert_equal 'Ṕḽḛḛααṡḛḛ, <a href="#test">ͼḽḭḭͼḳ ḥḛḛṛḛḛ</a>!', @backend.translate(:en, 'Please, <a href="#test">click here</a>!', {})
  end

  def test_it_works_with_http_links
    assert_equal 'Ṕḽḛḛααṡḛḛ, http://google.com/search ḭḭṡ ṭḥḛḛ 💩!', @backend.translate(:en, 'Please, http://google.com/search is the 💩!', {})
  end

  def test_it_works_with_hashes
    assert_equal({ name: 'Ḥḛḛḽḽṓṓ, ẁṓṓṛḽḍ!' }, @backend.translate(:en, { name: 'Hello, world!' }, {}))
  end

  def test_it_works_with_arrays
    assert_equal(['Ḥḛḛḽḽṓṓ, ẁṓṓṛḽḍ!'], @backend.translate(:en, ['Hello, world!'], {}))
  end

  def test_it_works_with_liquid_tags
    assert_equal('Ḥḛḛḽḽṓṓ, ẁṓṓṛḽḍ {{ firstname }} {{lastname}}!', @backend.translate(:en, 'Hello, world {{ firstname }} {{lastname}}!', {}))
  end
end
