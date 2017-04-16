# KindleManager

[![Gem Version](https://badge.fury.io/rb/kindle_manager.svg)](https://badge.fury.io/rb/kindle_manager)
[![Build Status](https://travis-ci.org/kyamaguchi/kindle_manager.svg?branch=master)](https://travis-ci.org/kyamaguchi/kindle_manager)

Scrape information of kindle books from amazon site

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kindle_manager'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kindle_manager

## Usage

### Setup

Create _.env_ following the instructions of https://github.com/kyamaguchi/amazon_auth

```
amazon_auth

vi .env
```

And `Dotenv.load` or `gem 'dotenv-rails'` may be required when you use this in your app.

### Run

```
bin/console
```

In console

```
client = KindleManager::Client.new(debug: true)
client.fetch_kindle_list
books = client.load_kindle_books

client.quit
```

#### Options

Debug print: `client = KindleManager::Client.new(debug: true)`

Limit fetching with number of fetched books: `client = KindleManager::Client.new(limit: 100)`

Change sleep duration on scrolling (default 3 seconds): `client = KindleManager::Client.new(fetching_interval: 5)`

##### Options of amazon_auth gem

Chrome driver: `driver: :chrome`

Renew the directory for downloading: `create: true`

Login and password: `login: 'xxx', password: 'yyy'`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kyamaguchi/kindle_manager.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

