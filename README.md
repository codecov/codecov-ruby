codecov-ruby [![Build Status](https://secure.travis-ci.org/codecov/codecov-ruby.svg?branch=master)](http://travis-ci.org/codecov/codecov-ruby) [![codecov.io](https://codecov.io/github/codecov/codecov-ruby/coverage.svg?branch=master)](https://codecov.io/github/codecov/codecov-ruby?branch=master)
=======
| [https://codecov.io/][1] | [@codecov][2] | [hello@codecov.io][3] |
| ------------------------ | ------------- | --------------------- |
=======

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
CODECOV_TOKEN="<your repo token>"
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
Jenkins, Travis CI, Codeship, Circle CI, Semaphore, drone.io, AppVeyor, Wercker, Magnum, Shippable, and Gitlab CI. Otherwise fallbacks on `git`.

### Enterprise
For companies using Codecov Enterprise you will need to specify the following parameters.
```sh
CODECOV_URL="https://codecov.mycompany.com"
CODECOV_SLUG="owner/repo"
CODECOV_TOKEN="repository token or global token"
```


[1]: https://codecov.io/
[2]: https://twitter.com/codecov
[3]: mailto:hello@codecov.io

## Copyright

> Copyright 2014 codecov
