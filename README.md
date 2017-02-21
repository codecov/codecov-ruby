codecov-ruby [![Build Status](https://secure.travis-ci.org/codecov/codecov-ruby.svg?branch=master)](http://travis-ci.org/codecov/codecov-ruby) [![codecov.io](https://codecov.io/github/codecov/codecov-ruby/coverage.svg?branch=master)](https://codecov.io/github/codecov/codecov-ruby?branch=master)

## Usage

> Add to your `Gemfile`

```ruby
gem 'codecov', :require => false, :group => :test
```

> Add to the top of your `tests/helper.rb` file

```ruby
require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov
```

> In your CI Environment Variables *(not needed for [https://travis-ci.org/](https://travis-ci.org/))*

```sh
CODECOV_TOKEN="your repo token"
```
Find you repo token on your repo page at [codecov.io][1]. Repo tokens are **not** required for public repos on Travis-Ci, CircleCI, or AppVeyor CI.

#### Submit only in CI example

```ruby
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
```

### CI Companies Supported
Jenkins, Travis CI, Codeship, Circle CI, Semaphore, drone.io, AppVeyor, Wercker, Magnum, Shippable, Gitlab CI, and Buildkite. Otherwise fallbacks on `git`.

### Caveat

1. There are known issues when `Simplecov.track_files` is enabled. We recommend that you require all code files in your tests so that Simplecov can provide Codecov with properly mapped coverage report metrics. [codecov/support#133]( https://github.com/codecov/support/issues/133)

2. Codecov, by default, ignored files that are not tested. Learn more at https://docs.codecov.io/docs/ruby

### Enterprise
For companies using Codecov Enterprise you will need to specify the following parameters.
```sh
CODECOV_URL="https://codecov.mycompany.com"
CODECOV_SLUG="owner/repo"
CODECOV_TOKEN="repository token or global token"
```


[1]: https://codecov.io/
