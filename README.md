# Minitest Bender

[![Gem Version](https://badge.fury.io/rb/minitest-bender.svg)](https://badge.fury.io/rb/minitest-bender)
[![Code Climate](https://codeclimate.com/github/eugeniobruno/minitest-bender.svg)](https://codeclimate.com/github/eugeniobruno/minitest-bender)

A comprehensive Minitest reporter.

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

Require this plugin right after Minitest, and then enable it explicitly:

```ruby
require 'minitest/autorun'
require 'minitest/bender'
Minitest::Bender.enable!
```

That's it! The next time you run your tests, a new report format will be used instead of the default one.

Instead of calling the `enable!` method, you can also specify the `--bender` test option, e.g.

    $ rake test TESTOPTS="--bender"

In both of these cases, Bender is activated with its default configuration. You can refer to [bender_plugin.rb](https://github.com/eugeniobruno/minitest-bender/blob/master/lib/minitest/bender_plugin.rb) or [configuration.rb](https://github.com/eugeniobruno/minitest-bender/blob/master/lib/minitest-bender/configuration.rb) to explore the multitude of options available to customize the output.

As an example, let's say your test suite takes several minutes to run, so you want to see detailed output in realtime. This behaviour is provided by a particular recorder called "progress_verbose", which is not the default one. In order to select this recorder for your app/gem, you can activate Bender like this instead:

```ruby
Minitest::Bender.enable!({ recorder: :progress_verbose })
```

You can also set configuration options via environment variables:

    $ BENDER_RECORDER=progress_verbose rake test

Finally, command-line options also work:

    $ rake test TESTOPTS="--bender-recorder=progress_verbose"

Bear in mind that setting a configuration option does not automatically enable the reporter, so remember to either call the `enable!` method, or to include the `--bender` argument.

If you use [minitest-reporters](https://github.com/kern/minitest-reporters) and have it installed and activated, you can select the `BenderReporter` as (one of the) reporters:

    $ MINITEST_REPORTER=BenderReporter,HtmlReporter rake test


## Features

Originally based on [minitest-colorin](https://github.com/gabynaiman/minitest-colorin/), the minitest-bender reporter offers you, out of the box, colored output including:

* A progress bar, mostly useful for long-running suites, as the default of many different recorders
* Status, running time, name and message for each test/expectation, grouped by class/context and sorted by name
* Details of skips, failures and errors, with diffs, backtraces and commands to rerun each single test
* Details of the slowest tests, if they may be relevant
* The same basic statistics of the default reporter

If the NO_COLOR environment variable is set, Bender will output non-colored text honoring [this standard](https://no-color.org/), thanks to the [paint gem](https://github.com/janlelis/paint/) dependency.


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eugeniobruno/minitest-bender. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

