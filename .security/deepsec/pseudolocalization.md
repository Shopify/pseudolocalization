# pseudolocalization

## What this codebase does

A small Ruby gem (v0.10.0, ~150 LOC of library code, MIT, published to
rubygems.org) that wraps a host Rails app's `I18n` backend and returns
_pretend_-translated strings so developers can spot missing translations and
over-long UI copy. `Pseudolocalization::I18n::Backend` decorates the real
backend, and `Pseudolocalization::I18n::Pseudolocalizer` maps ASCII letters to
UTF-8 lookalikes via the `LETTERS` table, doubling vowels via `VOWELS`. It
preserves HTML comments/tags, Liquid output and tags, `%{}` interpolation,
URLs, and character references using one compiled allowlist regex,
`ESCAPED_REGEX`. Dependencies are dev-only (`rake`, `minitest`); the library
itself needs no network, DB, filesystem, or subprocess access. Entry points are
`lib/pseudolocalization.rb` and `lib/pseudolocalization/pseudolocalizer.rb`.

## Auth shape

There is no authentication, authorization, session, or user model anywhere in
this repo — it is a library, not a service. The trust boundaries to reason
about instead:

- **Activation gate lives in the host app, not here.** The README's
  initializer pattern (`if Rails.env.development? && ENV["I18N_BACKEND"]`,
  requiring `pseudolocalization` and swapping `I18n.backend`) is the only thing
  keeping pseudo strings out of production; the gem itself never checks
  `Rails.env` or `RACK_ENV`.
- **`Backend#translate(locale, key, options)` and `#translations`** are the
  whole mutating surface. Both delegate to `original_backend` and post-process.
- **`ignores` (`attr_accessor`)**: host-supplied allowlist of `String` globs
  matched with `File.fnmatch` and `Regexp` matched with `key.to_s.match`;
  consulted by `key_ignored?` and by `pseudolocalize_node` on the joined scope.
- **`method_missing` / `respond_to_missing?`** forward every other method to
  `original_backend.public_send`, so the decorator inherits the real backend's
  full public API unfiltered.
- **`ESCAPED_REGEX`** is the only allowlist for "leave this substring alone";
  anything it fails to match is rewritten.

## Threat model

This gem holds no secrets, money, or customer data, so the realistic targets
are ranked low: (1) denormalizing or DoSing a _development/preview_ host app by
feeding pathological translation strings into `ESCAPED_REGEX` or keys into
`File.fnmatch` (CWE-1333 was fixed in 0.10.0 and is regression-tested); (2)
leaking pseudo-localized or ignore-bypassed copy into production because the
host app's `Rails.env`/`I18N_BACKEND` guard is misconfigured; (3) corrupting
markup/interpolation so a preview deploys broken HTML or Liquid. Supply chain
is the highest-impact path: the gemspec publishes to rubygems.org and CI runs on
GitHub Actions.

## Project-specific patterns to flag

- **New alternations in `ESCAPED_REGEX`** (`pseudolocalizer.rb`) that
  reintroduce lazy `.*?` or nested quantifiers. `test_escaped_regex_is_linear_time`
  and `test_many_unterminated_openers_complete_in_linear_time` are the guard;
  flag any edit that weakens them or adds an unbounded token.
- **Capturing groups in `ESCAPED_REGEX`**: `translate_string` calls
  `string.split(ESCAPED_REGEX)`, which splices captured groups into the output.
  Every group today is `(?:...)`; a plain `(...)` silently corrupts strings and
  can widen what reaches the host app.
- **Ignore matching with non-literal input**: `key_ignored?` runs
  `File.fnmatch(ignore, key.to_s)` and `key.to_s.match(ignore)` on host-supplied
  patterns; flag patterns sourced from ENV/params, and note the unsupported-type
  branch calls `Rails.logger.tagged`, which raises `NameError` outside Rails.
- **Widening `method_missing` / `respond_to_missing?`**: the decorator proxies
  arbitrary names to `original_backend.public_send`. Any change that routes
  `translate`/`translations` around `Pseudolocalizer.pseudolocalize`, or forwards
  to private/sensitive backend internals, defeats the point of the wrapper.
- **Unbounded recursion in `pseudolocalize_node` / `translate_object`**: both
  walk arbitrarily nested Hash/Array trees with no depth limit and `scope`
  accumulation, so a cyclic translation table raises `SystemStackError`.

## Known false-positives

- `test/pseudolocalization_test.rb` is full of attack-shaped fixtures —
  `opener * 100_000` inputs, `&foo-bar;`, `https://x.io/Don't_Look_Up`, unclosed
  `{{`/`%{`/`<!--` — used to assert linear-time and correct preservation, not
  exploitable code paths.
- `test/test_helper.rb` `$LOAD_PATH.unshift`, `bin/setup`, and `bin/console` are
  local dev scaffolding (bundler + `IRB.start`), not runtime entry points.
- `DummyBackend#translate` in the test file returning the key unchanged, and
  `original_backend.send(:init_translations)` in the backend, are intentional:
  the latter reaches I18n's private init API on purpose.
- `pseudolocalization.gemspec`'s `git ls-files` file list and
  `allowed_push_host` metadata are standard gem packaging with no interpolation
  of external input; `dev.yml` and the empty `service.yml` (`--- {}`) are local
  task definitions.
