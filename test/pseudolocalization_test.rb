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

  def test_markup_may_span_a_newline
    assert_equal("αα <span\nclass=\"x\">ḅ</span>", @backend.translate(:en, "a <span\nclass=\"x\">b</span>", {}))
    assert_equal("αα {{\n name }} ḅ", @backend.translate(:en, "a {{\n name }} b", {}))
    assert_equal("αα <!--\n note\n--> ḅ", @backend.translate(:en, "a <!--\n note\n--> b", {}))
  end

  def test_a_less_than_sign_that_does_not_start_a_tag_is_text
    assert_equal('3<4 ααṇḍ 5>2', @backend.translate(:en, '3<4 and 5>2', {}))
    assert_equal('αα < ḅ <br/> ͼ > ḍ', @backend.translate(:en, 'a < b <br/> c > d', {}))
    assert_equal("Ṫααḡ '<%{tag_name}>' ḭḭṡ ṇṓṓṭ ṗḛḛṛṃḭḭṭṭḛḛḍ", @backend.translate(:en, "Tag '<%{tag_name}>' is not permitted", {}))
  end

  def test_html_comments_and_doctype_are_preserved
    assert_equal("<!-- don't > \"do\" that --> ẋ", @backend.translate(:en, "<!-- don't > \"do\" that --> x", {}))
    assert_equal('<!DOCTYPE html> ẋ', @backend.translate(:en, '<!DOCTYPE html> x', {}))
  end

  def test_liquid_strings_may_contain_braces
    assert_equal('{{ x | default: "{" }} ẋ', @backend.translate(:en, '{{ x | default: "{" }} x', {}))
    assert_equal("{{ d | date: '%B %e, %Y' }} ẋ", @backend.translate(:en, "{{ d | date: '%B %e, %Y' }} x", {}))
  end

  def test_liquid_tags_are_preserved
    assert_equal('ṎṎṛḍḛḛṛ {{ name }}{% if customer.name %} ṗḽααͼḛḛḍ ḅẏẏ {{ customer.name }}{% endif %}',
      @backend.translate(:en, 'Order {{ name }}{% if customer.name %} placed by {{ customer.name }}{% endif %}', {}))
    assert_equal('{%- if a contains "50%" -%}ẋ{% endif %}', @backend.translate(:en, '{%- if a contains "50%" -%}x{% endif %}', {}))
    assert_equal("ṡẏẏṇṭααẋ ('{{', '}}', '{%' ṓṓṛ '%}')", @backend.translate(:en, "syntax ('{{', '}}', '{%' or '%}')", {}))
  end

  def test_a_url_ends_at_a_tag
    assert_equal('https://x.com/a?b=1&c=2<br>Ṅṓṓẁ', @backend.translate(:en, 'https://x.com/a?b=1&c=2<br>Now', {}))
    assert_equal("https://x.io/Don't_Look_Up ẋ", @backend.translate(:en, "https://x.io/Don't_Look_Up x", {}))
  end

  def test_only_well_formed_character_references_are_preserved
    assert_equal('&amp; &#39; &#x27; &frac12; &ϝṓṓṓṓ-ḅααṛ; ḀḀṪ&Ṫ', @backend.translate(:en, '&amp; &#39; &#x27; &frac12; &foo-bar; AT&T', {}))
  end

  def test_unterminated_openers_are_pseudolocalized_as_text
    assert_equal('αα <ḅ ͼ', @backend.translate(:en, 'a <b c', {}))
    assert_equal('αα {{ ḅ ͼ', @backend.translate(:en, 'a {{ b c', {}))
    assert_equal('αα %{ḅ ͼ', @backend.translate(:en, 'a %{b c', {}))
    assert_equal('αα &ḅ ͼ', @backend.translate(:en, 'a &b c', {}))
  end

  def test_a_nested_opener_ends_the_outer_token
    assert_equal('αα <ḅ <i>ͼ</i> ḍ', @backend.translate(:en, 'a <b <i>c</i> d', {}))
    assert_equal('αα {{ ḅ | ϝ: {ͼ} }} ḍ', @backend.translate(:en, 'a {{ b | f: {c} }} d', {}))
    assert_equal('αα %{ḅ{ͼ} ḍ', @backend.translate(:en, 'a %{b{c} d', {}))
    assert_equal('αα &ḅ&amp; ͼ', @backend.translate(:en, 'a &b&amp; c', {}))
  end

  def test_quoted_attribute_values_can_contain_angle_brackets
    assert_equal('<a title="a < b">ḽḭḭṇḳ</a>', @backend.translate(:en, '<a title="a < b">link</a>', {}))
    assert_equal("<a title='a > b'>ḽḭḭṇḳ</a>", @backend.translate(:en, "<a title='a > b'>link</a>", {}))
  end

  def test_many_unterminated_openers_complete_in_linear_time
    ['<', '</"', "</'", '<!--', '<!-- -', '{{', '{{"', "{{'", '{%', '{% "', '%{', '&', '&#'].each do |opener|
      input = opener * 100_000
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      assert_equal(input, @backend.translate(:en, input, {}))
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
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

  def test_it_allows_only_cetain_locales
    @backend.only_locales = [:en]

    assert_equal('Ignore me, World!', @backend.translate(:fr, 'Ignore me, World!', {}))
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
