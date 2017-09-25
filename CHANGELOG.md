# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Changed
- Removed named parameters from `Puppetfile#initialize` to support older Rubies.

### Fixed
- Proper status for `kept at ...` messages.
- Return earlier on `:matched` status so that no re-ordering of parameters can occur.

## [0.2.0] - 2017-09-25
### Added
- Merge function.

## [0.1.0] - 2017-09-20 [YANKED]
### Added
- Initial release.
