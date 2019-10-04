# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/). This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Added `ci_url` to `service.yml`. [#27](https://github.com/shopify/pseudolocalization/pull/27)
- Added this CHANGELOG.md. [#32](https://github.com/Shopify/pseudolocalization/pull/32)
- Switched to Ruby 2.6.5 for development. [#33](https://github.com/Shopify/pseudolocalization/pull/33)

### Changed
- Upgraded `minitest` to v5.12.0. [#29](https://github.com/shopify/pseudolocalization/pull/29)
- Upgraded `rake` to v13.0.0. [#30](https://github.com/shopify/pseudolocalization/pull/30)
- Upgraded `minitest` to v5.12.2. [#31](https://github.com/shopify/pseudolocalization/pull/31)

### Fixed
- Properly load README badges. [#28](https://github.com/shopify/pseudolocalization/pull/28)

## [0.8.1] - 2019-08-23
### Added
- Added Dependabot. (https://github.com/Shopify/pseudolocalization/pull/23)

### Changed
- Switched to Ruby 2.6.3 for development. [#22](https://github.com/Shopify/pseudolocalization/pull/22)
- Switched to Travis CI for CI solutions. [#22](https://github.com/Shopify/pseudolocalization/pull/22)
- Upgraded to package_cloud 0.3.05. [#24](https://github.com/Shopify/pseudolocalization/pull/24)
- Upgraded to Rake 12.3. [#25](https://github.com/Shopify/pseudolocalization/pull/25)

### Removed
- Removed Shopify Build CI. [#22](https://github.com/Shopify/pseudolocalization/pull/22)

## [0.8.0] - 2019-08-13
### Added

- Exposed `original_backend` on the backend via `attr_reader`. [#21](https://github.com/Shopify/pseudolocalization/pull/21)

### Fixed

- Escape quotes inside attributes. [#20](https://github.com/Shopify/pseudolocalization/pull/20)


Please refer to [GitHub releases](https://github.com/Shopify/pseudolocalization/releases) for releases prior to [0.8.0].

[Unreleased]: https://github.com/Shopify/pseudolocalization/compare/0.8.1...HEAD
[0.8.1]: https://github.com/Shopify/pseudolocalization/compare/0.8.0...0.8.1
[0.8.0]: https://github.com/Shopify/pseudolocalization/compare/0.7.0...0.8.0
