🚨🚨 Deprecation Notice 🚨🚨

This uploader is being deprecated by the Codecov team. We recommend migrating to our [new uploader](https://docs.codecov.com/docs/codecov-uploader) as soon as possible to prevent any lapses in coverage. 

You can visit our [migration guide](https://docs.codecov.com/docs/deprecated-uploader-migration-guide#ruby-uploader) for help moving to our new uploader, and our blog post to learn more about our [deprecation plan](https://about.codecov.io/blog/codecov-uploader-deprecation-plan/),

**On February 1, 2022 this uploader will be completely deprecated and will no longer be able to upload coverage to Codecov.**

# Codecov Ruby Uploader

[![Codecov](https://codecov.io/github/codecov/codecov-ruby/coverage.svg?branch=master)](https://codecov.io/github/codecov/codecov-ruby?branch=master)
[![Gem Version](https://badge.fury.io/rb/codecov.svg)](https://rubygems.org/gems/codecov)
[![Build Status](https://secure.travis-ci.org/codecov/codecov-ruby.svg?branch=master)](http://travis-ci.org/codecov/codecov-ruby)
[![Codecov](https://circleci.com/gh/codecov/codecov-ruby.svg?style=svg)](https://circleci.com/gh/codecov/codecov-ruby)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fcodecov%2Fcodecov-ruby.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2Fcodecov%2Fcodecov-ruby?ref=badge_shield)


[Codecov.io](https://codecov.io/) upload support for Ruby.

## Quick Start

Add to your `Gemfile`:

```ruby
gem 'codecov', require: false, group: 'test'
```

Add to the top of your `tests/helper.rb` file:

```ruby
require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov
```

Add CI Environment Variable:

```sh
CODECOV_TOKEN="your repo token"
```

Find you repo token on your repo page at [codecov.io](https://codecov.io).
Repo tokens are **not** required for public repos on Travis-Ci, CircleCI, or AppVeyor CI.

## Supported CIs
| CI/CD |
| ----- |
| [AppVeyor CI](https://www.appveyor.com/) |
| [Azure Pipelines](https://azure.microsoft.com/en-us/services/devops/pipelines/) |
| [Bitbucket Pipelines](https://bitbucket.org/product/features/pipelines) |
| [Bitrise CI](https://www.bitrise.io/) |
| [Buildkite CI](https://buildkite.com/) |
| [CodeBuild CI](https://aws.amazon.com/codebuild/) |
| [CodePipeline](https://aws.amazon.com/codepipeline/) |
| [Circle CI](https://circleci.com/) |
| [Codeship CI](https://codeship.com/) |
| [Drone CI](https://drone.io/) |
| [GitLab CI](https://docs.gitlab.com/ee/ci/) |
| [Heroku CI](https://www.heroku.com/continuous-integration) |
| [Jenkins CI](https://www.jenkins.io/) |
| [Semaphore CI](https://semaphoreci.com/) |
| [Shippable](https://www.shippable.com/) |
| [Solano CI](https://xebialabs.com/technology/solano-ci/) |
| [TeamCity CI](https://www.jetbrains.com/teamcity/) |
| [Travis CI](https://travis-ci.org/) |
| [Wercker CI](https://devcenter.wercker.com/) |

## Advanced Usage

#### Submit only in CI example

```ruby
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
```

## Useful Links

[FAQ](https://docs.codecov.io/docs/frequently-asked-questions)
[Recipe List](https://docs.codecov.io/docs/common-recipe-list)
[Error Reference](https://docs.codecov.io/docs/error-reference)
[Changelog](./CHANGELOG.md)
[Support](https://codecov.io/support)
[Community Boards](https://community.codecov.io)

## Caveats

1. There are known issues when `Simplecov.track_files` is enabled. We recommend that you require all code files in your tests so that SimpleCov can provide Codecov with properly mapped coverage report metrics. [codecov/support#133]( https://github.com/codecov/support/issues/133)
  - https://github.com/colszowka/simplecov/blob/master/README.md#default-root-filter-and-coverage-for-things-outside-of-it
2. `git` must be installed.
  - https://github.com/codecov/codecov-ruby/blob/5e3dae3/lib/codecov.rb#L284-L295

## Maintainers

- [thomasrockhu](https://github.com/thomasrockhu)

## Enterprise

For companies using Codecov Enterprise you will need to specify the following parameters:

```sh
CODECOV_URL="https://codecov.mycompany.com"
CODECOV_SLUG="owner/repo"
CODECOV_TOKEN="repository token or global token"
```

## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2Fcodecov%2Fcodecov-ruby.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2Fcodecov%2Fcodecov-ruby?ref=badge_large)
