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

  def test_it_exposes_original_backend
    assert_instance_of DummyBackend, @backend.original_backend
  end

  def test_it_pseudolocalizes
    assert_equal 'Ḥḛḛḽḽṓṓ, ẁṓṓṛḽḍ!', @backend.translate(:en, 'Hello, world!', {})
  end

  def test_it_works_with_html_entities
    assert_equal 'Ṕḽḛḛααṡḛḛ, <a href="#test">ͼḽḭḭͼḳ ḥḛḛṛḛḛ</a>!', @backend.translate(:en, 'Please, <a href="#test">click here</a>!', {})
  end

  def test_it_does_not_pseudolocalize_html_entities
    assert_equal(
      '<span bind="func(&quot;product&quot;)"></span>',
      @backend.translate(:en, '<span bind="func(&quot;product&quot;)"></span>', {})
    )
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
  
  def test_it_works_with_templates
    assert_equal('Ḥḛḛḽḽṓṓ, ẁṓṓṛḽḍ %{firstname} %{lastname}!', @backend.translate(:en, 'Hello, world %{firstname} %{lastname}!', {}))
  end

  def test_it_allows_ignoring_cetain_keys
    @backend.ignores = ['Ignore*', /Clifford.$/]

    assert_equal('Ignore me, World!', @backend.translate(:en, 'Ignore me, World!', {}))
    assert_equal('Ignore me, as well Clifford!', @backend.translate(:en, 'Ignore me, as well Clifford!', {}))
  end
end
