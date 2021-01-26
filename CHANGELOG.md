### `0.4.1`
- #133 Write down to file when using the formatter

### `0.4.0`
- #130 Split uploader from formatter

### `0.3.0`
- #124 Ruby 3.0 support
- #125 open simplecov requirement to 0.21.x

### `0.2.15`
- #118 Include codecov/version in the gem

### `0.2.14`
- #107 Add EditorConfig file
- #113 Return version constant, don't duplicate version value
- #117 Update simplecov dependency versions

### `0.2.13`
- [#105](https://github.com/codecov/codecov-ruby/pull/105) Remove unnecessary dependency for ruby standard gem
- [#110](https://github.com/codecov/codecov-ruby/pull/110) Fix GitHub Actions
- [#111](https://github.com/codecov/codecov-ruby/pull/111) Fix branch name detection for GitHub Actions CI

### `0.2.12`
- [#102](https://github.com/codecov/codecov-ruby/pull/102) Fix value of params[:pr] when useing CodeBuild

### `0.2.11`
- Add vendor/ to invalid directories

### `0.2.10`
- Adds better logging on error cases
- Add more invalid directories in the network

### `0.2.9`
- Remove `String` specific colors
- Add support for Codebuild CI

### `0.2.8`
- Remove `colorize` dependency

### `0.2.7`
- Fix for enterprise users unable to upload using the v4 uploader

### `0.2.6`
- Fix issue with `push` events on GitHub Actions

### `0.2.5`
- Revert single use of VERSION

### `0.2.4`
- Adds support for GitHub Actions CI

### `0.2.3`
- Support uploads for jruby 9.1 and 9.2

### `0.2.2`
- Handle SocketError and better error handling of v4 failures

### `0.2.1`
- Properly handle 400 cases when using the v4 endpoint

### `0.2.0`
- move to the v4 upload endpoint with the v2 as a fallback

### `0.1.20`
- fix critical upload issues on V2 endpoint

### `0.1.19`
- fix colorize

### `0.1.18`
- refactor and move to use v2 endpoint
- use Timeout::Error

### `0.1.17`
- refactor upload method and add more logging

### `0.1.10`
- update numerous ci environments
- dont fail if cannot upload to codecov

### `0.1.3`
- add buildkite

### `0.1.2`
- add slug argument
- use slug for uploading
- add Accept to uploads

### `0.1.1`
- fix #6, thanks @justmatt
- add semaphore thread number

### `0.1.0`
- added more CircleCI env

### `0.0.11`
- send AppVeyor pr# with reports

### `0.0.10`
- fix AppVeyor for public repos

### `0.0.9`
- remove tmp.json creation

### `0.0.8`
- added more jenkins environment references

### `0.0.7`
- added GitLab CI Runner support

### `0.0.5`
- added line messages by @coderanger
- fixed skip lines during reporting by @coderanger

### `0.0.4`
- added more test
- added more CI providers
