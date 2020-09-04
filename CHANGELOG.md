### `0.2.10`
- Adds better logging on error cases

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
