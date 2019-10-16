# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Changed
- [GH-3](https://github.com/pegasd/puppetfile_editor/issues/3): Write local modules in non-legacy format: `, local: true`.

## [0.10.0] - 2019-08-10
### Added
- [GH-3](https://github.com/pegasd/puppetfile_editor/issues/3): Able to understand local modules in various formats. Both `, :local` and
  `, local: true` work.

## [0.9.0] - 2019-08-06
### Changed
- Add ability to compare Puppetfiles ignoring module types (`git` vs `hg`).

## [0.8.0] - 2018-07-12
### Changed
- [GH-1](https://github.com/pegasd/puppetfile_editor/issues/1): Do not downgrade modules while merging, whenever possible (see issue for
  more details).
- Changed status message and color for modules not found in original Puppetfile (old one generated too much noise).


## [0.7.1] - 2018-02-22
### Fixed
- Fix for older rubies where `Gem::Version` broke for versions like `0.1.0-dev1`.

## [0.7.0] - 2018-02-15
### Added
- Warn about downgrading forge, git, and hg modules while merging.

## [0.6.1] - 2017-12-11
### Fixed
- Changed default CLI path to `Puppetfile` instead of `./Puppetfile` for better auditing.

## [0.6.0] - 2017-11-01
### Changed
- `Puppetfile#compare_with` now stores module type in the resulting diff.

### Fixed
- `Puppetfile#compare_with` didn't properly work with forge modules. It does now.

## [0.5.0] - 2017-10-23
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
