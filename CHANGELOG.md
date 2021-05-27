# Version: 0.3.6


#### Other Changes

* [#25](https://github.com/greymatter-io/gmenv/pull/25): Update version url pattern and introduce backwards-compatible fetching

# Version: 0.3.4/0.3.5/0.3.6

#### Bug Fixes
* [#32](https://github.com/greymatter-io/gmenv/pull/32): Fixes the sort when
    calling list-remote


# Version 0.3.3


#### Bug Fixes
* [#24](https://github.com/greymatter-io/gmenv/pull/25): Corrected URL fetching to reflect new artifact naming and introduced fallback fetching for older artifacts
* Fixed looping bug in tests preventing some of them from running
* Replaced the command used in testing,`greymatter --version`, with `greymatter version`, which has support across all versions of the CLI

# Version: 0.3.2


#### Bug Fixes

* [#20](https://github.com/greymatter-io/gmenv/pull/20): Fix gmenv verison
* [#21](https://github.com/greymatter-io/gmenv/pull/21): Fix a bug when latest and other versions were installed at same time


# Version: 0.3.1


#### Other Changes

* [#18](https://github.com/greymatter-io/gmenv/pull/18): Update for new latest binary path


# Version: 0.3.0


#### Code Improvements


* [#14](https://github.com/greymatter-io/gmenv/pull/14): Upgrade to retrieve binaries from new Nexus server

#### Other Changes

* [#15](https://github.com/greymatter-io/gmenv/pull/15): Add ability to download latest from development
* [#16](https://github.com/greymatter-io/gmenv/pull/16): fix test on release


# Version: 0.2.3


#### Other Changes

* [#12](https://github.com/greymatter-io/gmenv/pull/12): add change log ci + change log 0.2.2



# Versin: 0.2.2 (May 2020)

* Added automated Releasing
* Fix [#6](https://github.com/greymatter-io/gmenv/issues/6): Prior versions are no longer lost when upgrading `gmenv`

# Version: 0.2.1 (May 2020)

* Fix [#4](https://github.com/greymatter-io/gmenv/issues/4): Moves the credentials config file to `${HOME}/.gmenv/credentials`

# Version: 0.2.0 (May 2020)

* Remove the dependency on bash4 for macOS

# Version: 0.1.0 (May 2020)

* Initial development of gmenv
