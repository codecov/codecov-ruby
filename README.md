# [codecov.io][1] [![Build Status](https://secure.travis-ci.org/codecov/codecov-ruby.svg?branch=master)](http://travis-ci.org/codecov/codecov-ruby)

| [https://codecov.io/][1] | [@codecov][2] | [hello@codecov.io][3] |
| ------------------------ | ------------- | --------------------- |

-----

## Usage

```ruby
gem 'codecov', :require => false, :group => :test
```
> Add to your Gemfile

```ruby
require 'simplecov'
require 'codecov'

SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::Codecov
```
> Add to the top of your `test/test_helper.rb` file

### Send only from CI
```
require 'simplecov'
SimpleCov.start
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
```


[1]: https://codecov.io/
[2]: https://twitter.com/codecov
[3]: mailto:hello@codecov.io
