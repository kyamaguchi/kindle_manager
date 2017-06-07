# KindleManager

[![Gem Version](https://badge.fury.io/rb/kindle_manager.svg)](https://badge.fury.io/rb/kindle_manager)
[![Build Status](https://travis-ci.org/kyamaguchi/kindle_manager.svg?branch=master)](https://travis-ci.org/kyamaguchi/kindle_manager)

Scrape information of kindle books from amazon site

##### Fetch Kindle Books information

![kindle_manager_fetch](https://cloud.githubusercontent.com/assets/275284/25068993/e3792780-22ae-11e7-9040-3a91d6b3dd08.gif)

##### Load books information

![kindle_manager_load_books](https://cloud.githubusercontent.com/assets/275284/25068999/139b3994-22af-11e7-9e57-3cd217fa82eb.gif)
Recorded with [Recordit](http://recordit.co/)

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

[chromedriver](https://sites.google.com/a/chromium.org/chromedriver/downloads) is required. Please [download chromedriver](http://chromedriver.storage.googleapis.com/index.html) and update chromedriver regularly.  

Create _.env_ following the instructions of https://github.com/kyamaguchi/amazon_auth

```
amazon_auth

vi .env
```

And `Dotenv.load` or `gem 'dotenv-rails'` may be required when you use this in your app.

### Run

In console

```
require 'kindle_manager'
client = KindleManager::Client.new(debug: true, limit: 1000)
client.fetch_kindle_list

books = client.load_kindle_books

client.quit
```

Once `fetch_kindle_list` succeeds, you can load books information of downloaded pages anytime.
(You don't need to fetch pages with launching browser every time.)

```
client = KindleManager::Client.new
books = client.load_kindle_books
```

#### Options

Debug print: `client = KindleManager::Client.new(debug: true)`

Limit fetching with number of fetched books: `client = KindleManager::Client.new(limit: 100)`

Change sleep duration on scrolling (default 3 seconds): `client = KindleManager::Client.new(fetching_interval: 5)`

Change max scroll attempts (default 20): `client = KindleManager::Client.new(max_scroll_attempts: 30)`

Renew the directory for downloading: `create: true`

##### Options of amazon_auth gem

Firefox: `driver: :firefox`

Login and password: `login: 'xxx', password: 'yyy'`

## Applications

Applications using this gem

- [tsundoku 積読](https://github.com/kyamaguchi/tsundoku)
- Let me know(create a pull request) if you create an app

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kyamaguchi/kindle_manager.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

