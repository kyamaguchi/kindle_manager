# KindleManager

[![Gem Version](https://badge.fury.io/rb/kindle_manager.svg)](https://badge.fury.io/rb/kindle_manager)
[![CircleCI](https://circleci.com/gh/kyamaguchi/kindle_manager.svg?style=svg)](https://circleci.com/gh/kyamaguchi/kindle_manager)

Scrape information of kindle books & highlights from amazon site

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

[chromedriver](https://sites.google.com/chromium.org/driver/) is required. Please [download chromedriver](https://chromedriver.storage.googleapis.com/index.html) and update chromedriver regularly.  

Create _.env_ following the instructions of https://github.com/kyamaguchi/amazon_auth

```
amazon_auth

vi .env
```

And `Dotenv.load` or `gem 'dotenv-rails'` may be required when you use this in your app.

### Run

#### Kindle books list

In console

```ruby
require 'kindle_manager'
client = KindleManager::Client.new(keep_cookie: true, verbose: true, limit: 1000)
client.fetch_kindle_list

books = client.load_kindle_books

client.quit
```

Once `fetch_kindle_list` succeeds, you can load books information of downloaded pages anytime.
(You don't need to fetch pages with launching browser every time.)

```ruby
client = KindleManager::Client.new
books = client.load_kindle_books
```

Example of data

```ruby
console> pp books.first.to_hash
{"asin"=>"B0026OR2TU",
 "title"=>
  "Rails Cookbook: Recipes for Rapid Web Development with Ruby (Cookbooks (O'Reilly))",
 "tag"=>"Sample",
 "author"=>"Rob Orsini",
 "date"=>Fri, 17 Mar 2017,
 "collection_count"=>0}
```

#### Kindle highlights and notes

In console

```ruby
require 'kindle_manager'
client = KindleManager::Client.new(keep_cookie: true, verbose: true, limit: 10)
client.fetch_kindle_highlights

books = client.load_kindle_highlights
```

Example of data

```ruby
console> pp books.first.to_hash
{"asin"=>"B004YW6M6G",
 "title"=>
  "Design Patterns in Ruby (Adobe Reader) (Addison-Wesley Professional Ruby Series)",
 "author"=>"Russ Olsen",
 "last_annotated_on"=>Wed, 21 Jun 2017,
 "highlights_count"=>8,
 "notes_count"=>7,
 "highlights_and_notes"=>
  [{"location"=>350,
    "highlight"=>
     "Design Patterns: Elements of Reusable Object-Oriented Software,",
    "color"=>"orange",
    "note"=>""},
   {"location"=>351,
    "highlight"=>"\"Gang of Four book\" (GoF)",
    "color"=>"yellow",
    "note"=>""},
   {"location"=>356, "highlight"=>nil, "color"=>nil, "note"=>"note foo"},
   ...
   {"location"=>385,
    "highlight"=>nil,
    "color"=>nil,
    "note"=>"object oriented"}]}
```

#### Options

Limit fetching with number of fetched books: `client = KindleManager::Client.new(limit: 100)`

Change sleep duration on scrolling (default 3 seconds): `client = KindleManager::Client.new(fetching_interval: 5)`

Change max scroll attempts (default 20): `client = KindleManager::Client.new(max_scroll_attempts: 30)`

Renew the directory for downloading: `create: true`

##### Options of amazon_auth gem

Firefox: `driver: :firefox`

Login and password: `login: 'xxx', password: 'yyy'`

Output debug log: `debug: true`

## Issues

There may be problems with capybara 3.  
Use older version with `gem 'capybara', '~> 2.18.0'` in that case.

## TODO

- Limit the number of fetching books by date

## Applications

Applications using this gem

- [tsundoku 積読](https://github.com/kyamaguchi/tsundoku)
- [kindle_highlight app](https://github.com/kyamaguchi/kindle_highlight)
- Let me know(create a pull request) if you create an app

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kyamaguchi/kindle_manager.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

