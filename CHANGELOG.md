# Changelog

## [Unreleased]

## [0.3.0] - 2024-08-06

### Added

- Add a changelog.
- Add [kmod](https://github.com/kmod-project/kmod) to the base tarball to enable loading of kernel modules.

### Changed

- Fix Makefile formatting and typo.
- Use `antonyurchenko/git-release` GitHub action that integrates with the changelog.
- Move the artifact builds into a common workflow.

## [0.2.0] - 2024-07-13

### Added

- Publish a new "build" artifact that includes a common `Makefile.inc` to be used both here and in the `github.com/cloudboss/easyto` repository.
- Pass the `-j` option to `make` for the `e2fsprogs` build.

### Changed

- Change the Makefile to use variables and targets from `Makefile.inc`.
- Use normal instead of lazy assignments in Makefile as the lazy assignments are not explicitly needed.
- Use order-only prerequsites in Makefile for directories whose timestamps change frequently but don't necessitate a rebuild.

### Removed

- Manage the Packer configuration and provisioning script in `github.com/cloudboss/easyto` instead of here, as changes to it align more closely with easyto changes. The packer binaries and plugins for every supported easyto architecture will still be packaged here.

[0.1.0]: https://github.com/cloudboss/easyto-assets/releases/tag/v0.1.0

## [0.1.0] - 2024-07-10

Initial release

[0.3.0]: https://github.com/cloudboss/easyto-assets/releases/tag/v0.3.0
[0.2.0]: https://github.com/cloudboss/easyto-assets/releases/tag/v0.2.0
[0.1.0]: https://github.com/cloudboss/easyto-assets/releases/tag/v0.1.0
