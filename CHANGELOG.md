# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
- `delete` command for deleting modules from Puppetfile.

## [0.4.0] - 2017-10-07
### Added
- Support for setting `changeset` for git/hg modules.

### Changed
- Color of `matched` output status changed to bright white so that other statuses stand out better.

### Fixed
- Force update when using 'edit' command from CLI.

## [0.3.1] - 2017-10-04
### Fixed
- `kept at` behavior:
  - `changeset` is now also part of the version to be kept back (`hg`, `git` modules).
  - Various cases where the version should have been kept, but wasn't, have now been fixed.

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
