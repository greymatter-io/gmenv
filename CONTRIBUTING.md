# Contributing

## Changelog

This repo uses [changelog-ci](https://github.com/saadmk11/changelog-ci) to
automatically keep a Change Log. When you're ready to snap a release, the title
of the PR needs to be of the format "Release X.Y.Z". This will
trigger the CI to properly build the changelog.

## Version Control

Running `gmenv --version` will print the version install. This is driven by the
value found on the first line of the [CHANGELOG.md](./CHANGELOG.md). This should
be updated to reflect the current release.

## Releasing

The release will occur when the appropriate tag is pushed to the repo.
