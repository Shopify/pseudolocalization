require "test_helper"

class PseudolocalizationTest < Minitest::Test
  class DummyBackend
    attr_accessor :translations

    def initialize(translations = {})
      @translations = translations
    end

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

  def test_that_it_supports_block_initialization
    Pseudolocalization::I18n::Backend.new(DummyBackend.new) do |instance|
      assert_instance_of Pseudolocalization::I18n::Backend, instance
    end
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

  def test_markup_never_spans_a_newline
    # Same as before the fix: `.` never matched "\n".
    assert_equal("αα <ṡṗααṇ\nͼḽααṡṡ=\"ẋ\">ḅ</span>", @backend.translate(:en, "a <span\nclass=\"x\">b</span>", {}))
    assert_equal("αα {{\n ṇααṃḛḛ }} ḅ", @backend.translate(:en, "a {{\n name }} b", {}))
  end

  def test_unterminated_openers_are_pseudolocalized_as_text
    assert_equal('αα <ḅ ͼ', @backend.translate(:en, 'a <b c', {}))
    assert_equal('αα {{ ḅ ͼ', @backend.translate(:en, 'a {{ b c', {}))
    assert_equal('αα %{ḅ ͼ', @backend.translate(:en, 'a %{b c', {}))
    assert_equal('αα &ḅ ͼ', @backend.translate(:en, 'a &b c', {}))
  end

  def test_a_nested_opener_ends_the_outer_token
    # The one behaviour change: an opener inside an unclosed token ends it,
    # instead of the token swallowing everything up to the first closer.
    assert_equal('αα <ḅ <i>ͼ</i> ḍ', @backend.translate(:en, 'a <b <i>c</i> d', {}))
    assert_equal('αα {{ ḅ | ϝ: {ͼ} }} ḍ', @backend.translate(:en, 'a {{ b | f: {c} }} d', {}))
    assert_equal('αα %{ḅ{ͼ} ḍ', @backend.translate(:en, 'a %{b{c} d', {}))
    assert_equal('αα &ḅ&amp; ͼ', @backend.translate(:en, 'a &b&amp; c', {}))
    # A raw `<` inside an attribute value counts too (HTML tools write `&lt;`).
    assert_equal('<αα ṭḭḭṭḽḛḛ="αα < b">ḽḭḭṇḳ</a>', @backend.translate(:en, '<a title="a < b">link</a>', {}))
  end

  def test_many_unterminated_openers_complete_in_linear_time
    # CWE-1333 guard. The old `<.*?>` took seconds here on Ruby < 3.2.
    require 'benchmark'

    ['<', '{{', '%{', '&'].each do |opener|
      input = opener * 100_000
      elapsed = Benchmark.realtime { assert_equal(input, @backend.translate(:en, input, {})) }
      assert_operator elapsed, :<, 2.0, "#{opener.inspect} * 100_000 took #{elapsed.round(2)}s"
    end
  end

  def test_escaped_regex_is_linear_time
    skip 'Regexp.linear_time? was added in Ruby 3.2' unless Regexp.respond_to?(:linear_time?)

    assert Regexp.linear_time?(Pseudolocalization::I18n::Pseudolocalizer::ESCAPED_REGEX)
  end

  def test_it_allows_ignoring_cetain_keys
    @backend.ignores = ['Ignore*', /Clifford.$/]

    assert_equal('Ignore me, World!', @backend.translate(:en, 'Ignore me, World!', {}))
    assert_equal('Ignore me, as well Clifford!', @backend.translate(:en, 'Ignore me, as well Clifford!', {}))
    assert_equal(['Ḥḛḛḽḽṓṓ, ẁṓṓṛḽḍ!'], @backend.translate(:en, ['Hello, world!'], {}))
  end

  def test_it_exposes_pseudo_localized_translations
    translations = {
      en: {
        date: {
          day_names: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        },
        hello: 'Hello, world!',
        ignored: {
          foobar: "Foobar"
        }
      },
      es: {
        date: {
          day_names: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'],
        },
        hello: 'Hola, mundo!',
        ignored: {
          foobar: "Foobar"
        }
      }
    }
    expected = {
      en: {
        date: {
          day_names: ["Ṣṵṵṇḍααẏẏ", "Ṁṓṓṇḍααẏẏ", "Ṫṵṵḛḛṡḍααẏẏ", "Ŵḛḛḍṇḛḛṡḍααẏẏ", "Ṫḥṵṵṛṡḍααẏẏ", "Ḟṛḭḭḍααẏẏ"],
        },
        hello: "Ḥḛḛḽḽṓṓ, ẁṓṓṛḽḍ!",
        ignored: {
          foobar: "Foobar"
        }
      },
      es: {
        date: {
          day_names: ["Ḍṓṓṃḭḭṇḡṓṓ", "Ḻṵṵṇḛḛṡ", "Ṁααṛṭḛḛṡ", "Ṁḭḭéṛͼṓṓḽḛḛṡ", "Ĵṵṵḛḛṽḛḛṡ", "Ṿḭḭḛḛṛṇḛḛṡ"],
        },
        hello: "Ḥṓṓḽαα, ṃṵṵṇḍṓṓ!",
        ignored: {
          foobar: "Foobar"
        }
      }
    }

    @backend = Pseudolocalization::I18n::Backend.new(DummyBackend.new(translations))
    @backend.ignores = ["ignored*"]

    assert_equal(expected, @backend.translations)
  end
end
