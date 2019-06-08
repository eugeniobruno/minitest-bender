# Minitest Bender

[![Gem Version](https://badge.fury.io/rb/minitest-bender.svg)](https://badge.fury.io/rb/minitest-bender)
[![Code Climate](https://codeclimate.com/github/eugeniobruno/minitest-bender.svg)](https://codeclimate.com/github/eugeniobruno/minitest-bender)

My own Minitest reporter, without blackjack but with a hook.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'minitest-bender'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minitest-bender

## Usage

Require this plugin just after Minitest:

```ruby
require 'minitest/autorun'
require 'minitest/bender'
```

That's it! The next time you run your tests, a new report format will be used instead of the default one.

## Features

Based on [minitest-colorin](https://github.com/gabynaiman/minitest-colorin/), the minitest-bender reporter gives you colored output including:

* Status, running time, name and message for each test/expectation, grouped by class/context
* Details of skips, failures and errors in three different sections, with diffs, backtraces and commands to rerun each single test
* Details of the top 3 slowest tests, if they may be relevant
* The same basic statistics of the default reporter


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eugeniobruno/minitest-bender. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

