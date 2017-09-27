# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.3.0] - 2017-09-27
### Added
- Puppetfile can be instantiated using provided contents.
- `Puppetfile#compare_with` method.

### Changed
- Removed named parameters from `Puppetfile#initialize` to support older Rubies.
- Moved all IO to `Puppetfile::CLI`.

### Fixed
- Proper status for `kept at ...` messages.
- Return earlier on `:matched` status so that no re-ordering of parameters can occur.
- Various CLI logic issues.

### Removed
- No more old_hashes support.

## [0.2.0] - 2017-09-25
### Added
- Merge function.

## [0.1.0] - 2017-09-20 [YANKED]
### Added
- Initial release.
