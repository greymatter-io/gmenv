
[![CircleCI](https://circleci.com/gh/greymatter-io/gmenv.svg?style=svg)](https://circleci.com/gh/greymatter-io/gmenv)

![Test](https://github.com/chrisbsmith/gmenv/workflows/Test/badge.svg)
![Release](https://github.com/chrisbsmith/gmenv/workflows/Release/badge.svg)

# gmenv

[Grey Matter CLI](https://www.greymatter.io/) version manager inspired by [tfenv](https://github.com/tfutils/tfenv)

## Support

Currently gmenv supports the following OSes

- Mac OS X (64bit)
- Linux
  - 64bit
- Windows (64bit) - only tested in git-bash - currently presumed failing due to symlink issues in git-bash

## Installation

### Automatic

Install via Homebrew

  ```console
  $ brew install greymatter-io/homebrew-greymatter/gmenv
  ```

### Manual

1. Check out gmenv into any path (here is `${HOME}/.gmenv`)

  ```console
  $ git clone https://github.com/greymatter-io/gmenv.git ~/.gmenv
  ```

2. Add `~/.gmenv/bin` to your `$PATH` any way you like

  ```console
  $ echo 'export PATH="$HOME/.gmenv/bin:$PATH"' >> ~/.bash_profile
  ```

  OR you can make symlinks for `gmenv/bin/*` scripts into a path that is already added to your `$PATH` (e.g. `/usr/local/bin`) `OSX/Linux Only!`

  ```console
  $ ln -s ~/.gmenv/bin/* /usr/local/bin
  ```

  On Ubuntu/Debian touching `/usr/local/bin` might require sudo access, but you can create `${HOME}/bin` or `${HOME}/.local/bin` and on next login it will get added to the session `$PATH`
  or by running `. ${HOME}/.profile` it will get added to the current shell session's `$PATH`.

  ```console
  $ mkdir -p ~/.local/bin/
  $ . ~/.profile
  $ ln -s ~/.gmenv/bin/* ~/.local/bin
  $ which gmenv
  ```

## Credentials

The Grey Matter CLI requires a Decipher LDAP account to download. There are three ways to provide your Decipher LDAP information to `gmenv` to authorize `gmenv` to download the Grey matter CLI

### Environment Variables

#### `GMENV_LDAP_USERNAME` and `GMENV_LDAP_PASSWORD`

`gmenv` accepts these environment variables and will perform all queries for the Grey Matter CLI without ever storing the LDAP information

```console
GMENV_LDAP_USERNAME=email@provider.com GMENV_LDAP_PASSWORD=someawesomepassword gmenv install 1.4.1
```

### From a Prompt at Runtime

If no credentials are provided as environment variables, `gmenv` will prompt the user for Decipher LDAP credentials. These credentials will be written to a `credentials` file stored in the `gmenv` root location.

```console
➜  gmenv git:(gmenv) ✗ ./bin/gmenv install 1.2.0
No credentials for Grey Matter found. Prompting for user credentials.
gmenv needs your Decipher LDAP credentials to retrieve Grey Matter from Nexus.
Your information will be temporarily stored in ${HOME}/.gmenv/credentials
Enter your Decipher LDAP usernane:
Enter your Decipher LDAP password:
```

### Credentials file

`gmenv` can read from a credentials file to retrieve the Grey Matter CLI

```console
echo "email@provider.com:someawesomepassword" > ${HOME}/.gmenv/credentials
```

## Usage

### gmenv install [version]

Install a specific version of the Grey Matter CLI.

If no parameter is passed, the version to use is resolved automatically via .greymatter-version files, defaulting to 'latest' if none are found.

If a parameter is passed, available options:

- `i.j.k` exact version to install
- `latest` is a syntax to install latest version
- `latest:<regex>` is a syntax to install latest version matching regex (used by grep -e)

```console
$ gmenv install
$ gmenv install 1.4.0
$ gmenv install latest
$ gmenv install latest:^0.8
$ gmenv install min-required
```

#### .greymatter-version

If you use a [.greymatter-version file](#greymatter-version-file), `gmenv install` (no argument) will install the version written in it.

### Credentials

The Grey Matter CLI requires a Decipher LDAP account to download. There are three ways to provide your Decipher LDAP information to `gmenv` to authorize `gmenv` to download the Grey matter CLI

#### Environment Variables

##### `GMENV_LDAP_USERNAME` and `GMENV_LDAP_PASSWORD`

`gmenv` accepts these environment variables and will perform all queries for the Grey Matter CLI without ever storing the LDAP information

```console
GMENV_LDAP_USERNAME=email@provider.com GMENV_LDAP_PASSWORD=someawesomepassword gmenv install 1.4.1
```

#### From a Prompt at Runtime

If no credentials are provided as environment variables, `gmenv` will prompt the user for Decipher LDAP credentials. These credentials will be written to a `credentials` file stored in the `gmenv` root location.

```console
➜  gmenv git:(gmenv) ✗ ./bin/gmenv install 1.2.0
No credentials for Grey Matter found. Prompting for user credentials.
gmenv needs your Decipher LDAP credentials to retrieve Grey Matter from Nexus.
Your information will be temporarily stored in ${GMENV_ROOT}/.gmenv/credentials
Enter your Decipher LDAP usernane:
Enter your Decipher LDAP password:
```

#### Credentials file

`gmenv` can read from a credentials file to retrieve the Grey Matter CLI

```console
echo "email@provider.com:someawesomepassword" > ${HOME}/.gmenv/credentials
```

### Environment Variables

#### GMENV

##### `GMENV_ARCH`

String (Default: amd64)

Specify architecture. Architecture other than the default amd64 can be specified with the `GMENV_ARCH` environment variable

```console
GMENV_ARCH=arm gmenv install 1.3.0
```

##### `GMENV_AUTO_INSTALL`

String (Default: true)

Should gmenv automatically install greymatter if the version specified by defaults or a `.greymatter-version` file is not currently installed.

```console
GMENV_AUTO_INSTALL=false greymatter list cluster
```

##### `GMENV_CURL_OUTPUT`

Integer (Default: 2)

Set the mechanism used for displaying download progress when downloading greymatter versions from the remote server.

* 2: v1 Behaviour: Pass `-#` to curl
* 1: Use curl default
* 0: Pass `-s` to curl

##### `GMENV_DEBUG`

Integer (Default: 0)

Set the debug level for GMENV.

* 0: No debug output
* 1: Simple debug output
* 2: Extended debug output, with source file names and interactive debug shells on error
* 3: Debug level 2 + Bash execution tracing

##### `GMENV_REMOTE`

String (Default: https://nexus.production.deciphernow.com)

To install from a remote other than the default

```console
GMENV_REMOTE=https://example.jfrog.io/artifactory/greymatter
```

##### `GMENV_REPO`

String (default: hosted)

Specify the Grey Matter repo to search and download the Grey Matter CLI. Options are `hosted` or `dev`

##### `GMENV_LDAP_USERNAME`

String (default: "")

Set a Decipher LDAP username to retrieve the Grey Matter CLI from the greymatter.io repository

##### `GMENV_LDAP_PASSWORD`

String (default: "")

Set a Decipher LDAP password to retrieve the Grey Matter CLI from the greymatter.io repository

#### Bashlog Logging Library

##### `BASHLOG_COLOURS`

Integer (Default: 1)

To disable colouring of console output, set to 0.

##### `BASHLOG_DATE_FORMAT`

String (Default: +%F %T)

The display format for the date as passed to the `date` binary to generate a datestamp used as a prefix to:

* `FILE` type log file lines.
* Each console output line when `BASHLOG_EXTRA=1`

##### `BASHLOG_EXTRA`

Integer (Default: 0)

By default, console output from gmenv does not print a date stamp or log severity.

To enable this functionality, making normal output equivalent to FILE log output, set to 1.

##### `BASHLOG_FILE`

Integer (Default: 0)

Set to 1 to enable plain text logging to file (FILE type logging).

The default path for log files is defined by /tmp/$(basename $0).log
Each executable logs to its own file.

e.g.

```console
BASHLOG_FILE=1 gmenv use latest
```

will log to `/tmp/gmenv-use.log`

##### `BASHLOG_FILE_PATH`

String (Default: /tmp/$(basename ${0}).log)

To specify a single file as the target for all FILE type logging regardless of the executing script.

##### `BASHLOG_I_PROMISE_TO_BE_CAREFUL_CUSTOM_EVAL_PREFIX`

String (Default: "")

*BE CAREFUL - MISUSE WILL DESTROY EVERYTHING YOU EVER LOVED*

This variable allows you to pass a string containing a command that will be executed using `eval` in order to produce a prefix to each console output line, and each FILE type log entry.

e.g.

```console
BASHLOG_I_PROMISE_TO_BE_CAREFUL_CUSTOM_EVAL_PREFIX='echo "${$$} "'
```
will prefix every log line with the calling process' PID.

##### `BASHLOG_JSON`

Integer (Default: 0)

Set to 1 to enable JSON logging to file (JSON type logging).

The default path for log files is defined by /tmp/$(basename $0).log.json
Each executable logs to its own file.

e.g.

```console
BASHLOG_JSON=1 gmenv use latest
```

will log in JSON format to `/tmp/gmenv-use.log.json`

JSON log content:

`{"timestamp":"<date +%s>","level":"<log-level>","message":"<log-content>"}`

##### `BASHLOG_JSON_PATH`

String (Default: /tmp/$(basename ${0}).log.json)

To specify a single file as the target for all JSON type logging regardless of the executing script.

##### `BASHLOG_SYSLOG`

Integer (Default: 0)

To log to syslog using the `logger` binary, set this to 1.

The basic functionality is thus:

```console
local tag="${BASHLOG_SYSLOG_TAG:-$(basename "${0}")}";
local facility="${BASHLOG_SYSLOG_FACILITY:-local0}";
local pid="${$}";

logger --id="${pid}" -t "${tag}" -p "${facility}.${severity}" "${syslog_line}"
```

##### `BASHLOG_SYSLOG_FACILITY`

String (Default: local0)

The syslog facility to specify when using SYSLOG type logging.

##### `BASHLOG_SYSLOG_TAG`

String (Default: $(basename $0))

The syslog tag to specify when using SYSLOG type logging.

Defaults to the PID of the calling process.

### gmenv use [version]

Switch a version to use

If no parameter is passed, the version to use is resolved automatically via .greymatter-version files, defaulting to 'latest' if none are found.

`latest` is a syntax to use the latest installed version

`latest:<regex>` is a syntax to use latest installed version matching regex (used by grep -e)

`min-required` will switch to the version minimally required by your greymatter sources (see above `gmenv install`)

```console
$ gmenv use
$ gmenv use 1.4.1 
$ gmenv use latest
$ gmenv use latest:^1.4
```

### gmenv uninstall &lt;version>

Uninstall a specific version of Terraform
`latest` is a syntax to uninstall latest version
`latest:<regex>` is a syntax to uninstall latest version matching regex (used by grep -e)

```console
$ gmenv uninstall 1.2.0
$ gmenv uninstall latest
$ gmenv uninstall latest:^1.2
```

### gmenv list

List installed versions

```console
% gmenv list
* 1.4.1 (set by /opt/gmenv/version)
  1.2.0
  1.3.0
  1.4.0
```

### gmenv list-remote

List installable versions

```console
% gmenv list-remote
1.2.1
1.1.0
1.0.3
1.0.2
1.0.1
1.0.0
0.5.1
0.5.0
0.4.1
0.4.0
0.3.0
0.2.0
0.1.0
...
```

## .greymatter-version file

If you put a `.greymatter-version` file on your project root, or in your home directory, gmenv detects it and uses the version written in it. If the version is `latest` or `latest:<regex>`, the latest matching version currently installed will be selected.

```console
$ cat .greymatter-version
1.3.0

$ greymatter --version
Grey Matter CLI
 Command Name:                  greymatter
 Version:                       v1.3.0
 Branch:                        release-1.3
 Commit:                        04b0f74
 Built:                         Wed, 15 Apr 2020 17:28:59 UTC by alecholmez
Grey Matter Control API
 Version:                       v1.3.0

$ echo 0.7.3 > .greymatter-version

$ greymatter --version
Terraform v0.7.3

$ echo latest:^1.4 > .greymatter-version

$ greymatter --version
Grey Matter CLI
 Command Name:                  greymatter
 Version:                       v1.4.1
 Branch:                        release-1.3
 Commit:                        04b0f74
 Built:                         Wed, 15 Apr 2020 17:28:59 UTC by alecholmez
Grey Matter Control API
 Version:                       v1.4.1```

## Upgrading

```console
$ git --git-dir=~/.gmenv/.git pull
```

## Uninstalling

```console
$ rm -rf /some/path/to/gmenv
```

## LICENSE

- [gmenv itself](https://github.com/greymatter-io/gmenv/blob/master/LICENSE)
- [tfenv](https://github.com/tfutils/gmenv/tfenv/blob/master/LICENSE)
  - gmenv uses the majority of tfenv's source code
- [rbenv](https://github.com/rbenv/rbenv/blob/master/LICENSE)