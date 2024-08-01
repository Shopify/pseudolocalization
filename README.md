# Pseudolocalization

[![Version][gem]][gem_url] [![Build Status](https://github.com/Shopify/pseudolocalization/workflows/CI/badge.svg?branch=main)](https://github.com/Shopify/pseudolocalization/actions?query=workflow%3ACI)

[About this repo](#about-this-repo) | [How to use this repo](#how-to-use-this-repo) | [Contribute to this repo](#contribute-to-this-repo)

## About this repo
### Why?

Internationalization is a hard and tedious process. Different character sets, different average word length, different pluralization rules... There's a lot going on and it's impossible to test against all possible scenarios. As a side effect, most of us will simply test against one or two known languages and hope for the best. Unfortunately, this often leads to broken UI elements, texts going out of bounds, or forgotten non-translated strings making their way into a final release.

As an example, let's examine the string "Set the power switch to 0.":

| Language | String | Characters | Percentage |
|----------|--------|------------|------------|
| English | Set the power switch to 0. | 26 chars | -
| French | Placez l'interrupteur de tension à 0. | 37 chars | 42% more
| Spanish | Ponga el interruptor de alimentación de corriente en 0. | 55 chars | 112% more

It's easy to see that any hardcoded widths would likely break giving such a string. IBM suggests that on average, we should expect any English string to inflate by 30% when translating in another language.

In an attempt to ease this whole process, we created a small tool that gives you the ability to preview your product with pseudo-translations in a way that will;

1. Identify untranslated strings
2. Expand words by doubling all vowels
3. Use English lookalike UTF8 characters for readability

For the example above, this looks like:

| Language | String | Characters | Percentage |
|----------|--------|------------|------------|
| Pseudo-English | Ṣḛḛṭ ṭḥḛḛ ṗṓṓẁḛḛṛ ṡẁḭḭṭͼḥ ṭṓṓ 0. | 32 chars | 23% more

## How to use this repo
### Installation

Add these lines to your application's Gemfile:

```ruby
group :development do
  gem 'pseudolocalization', require: false
end
```

Execute:

    $ bundle

Finally, in an initializer, add the following lines:

```ruby
if Rails.env.development? && ENV["I18N_BACKEND"]
  case ENV["I18N_BACKEND"]
  when 'pseudolocalization'
    require 'pseudolocalization'
    I18n.backend = Pseudolocalization::I18n::Backend.new(I18n.backend)
  end
end
```

### Usage

When working on internationalization, you can boot your server with the pseudolocalization backend to quickly identify content that doesn't go through the I18n framework.

```bash
I18N_BACKEND=pseudolocalization bundle exec rails server
```

### Ignoring specific keys
You may wish to have the backend ignore specific keys. These may be configured via an array, `ignores`, on the backend. The array can contain a mix of strings (with globbing allowed) and/or Regexes.

```ruby
I18n.backend = Pseudolocalization::I18n::Backend.new(I18n.backend)
I18n.backend.ignores = ['ignored*', /Waldo.$/]
```

### How to run tests

```bash
bundle exec rake test
```

### Other Resources

* [IBM Globalization Guidelines](http://www-01.ibm.com/software/globalization/guidelines/index.html)
* [Design for internationalization - Dropbox Design](https://medium.com/dropbox-design/design-for-internationalization-24c12ea6b38f)
* [Pseudolocalization](https://en.wikipedia.org/wiki/Pseudolocalization)
* [Essential Guide to App Internationalization](https://drive.google.com/open?id=1c6nAw6ttF_uHRq0ZQaGu5gYD0vjq9lHP)
* [Pseudo Localization @ Netflix](https://medium.com/netflix-techblog/pseudo-localization-netflix-12fff76fbcbe)

## Contribute to this repo

Bug reports and pull requests are welcome on GitHub at https://github.com/Shopify/pseudolocalization.

[gem]: https://badgen.net/rubygems/v/pseudolocalization?color=green
[gem_url]: https://rubygems.org/gems/pseudolocalization
