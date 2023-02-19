# Trains

A gem that statically analyses your Rails app and extracts information about its structure.

[![DeepSource](https://deepsource.io/gh/faraazahmad/trains.svg/?label=active+issues&show_trend=true&token=RKfXNZL_RQe6j2NEhXv2iOeh)](https://deepsource.io/gh/faraazahmad/trains/?ref=repository-badge)
[![DeepSource](https://deepsource.io/gh/faraazahmad/trains.svg/?label=resolved+issues&show_trend=true&token=RKfXNZL_RQe6j2NEhXv2iOeh)](https://deepsource.io/gh/faraazahmad/trains/?ref=repository-badge)

## Index

1. [Installation](#installation)
2. [Usage](#usage)
3. [Features](#features)
    1. [Create Model definitions from migrations](#create-model-definitions-from-migrations)
    2. [Create controller definitions from files](#create-controller-definitions-from-files)
4. [Development](#development)
5. [Contributing](#contributing)
6. [License](#license)
7. [Code of conduct](#code-of-conduct)

## Installation

Install the gem and add it to the application's Gemfile by executing:

    $ bundle add trains

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install trains

## Usage

```ruby
require 'trains'

scanner = Trains::Scanner.new('~/lib/trains_app')
result = scanner.scan
```

## Features

Trains currently has the ability to achieve the following:

### Create Model definitions from migrations

Given a DB migration in your Rails app like so:

```ruby
class CreateGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :groups do |t|
      t.string :title

      t.timestamps
    end
    add_index :groups, :title, unique: true
  end
end
```

Trains will generate the following Model definition:

```ruby
Trains::DTO::Model(
  name: 'Group',
  fields:
    [
      Trains::DTO::Field(:title, :string),
      Trains::DTO::Field(:created_at, :datetime),
      Trains::DTO::Field(:updated_at, :datetime),
    ],
  version: 7.0
)
```

### Create Controller definitions from files

Given a controller in your Rails app like so:

```ruby
class BoxController < ApplicationController
  def create; end

  def edit; end

  def update; end

  def destroy; end
end
```

Trains will return the following controller definition:

```ruby
Trains::DTO::Controller(
    name: 'BoxController',
    method_list: [
      Trains::DTO::Method(name: 'create', visibility: nil, source: nil),
      Trains::DTO::Method(name: 'edit', visibility: nil, source: nil),
      Trains::DTO::Method(name: 'update', visibility: nil, source: nil),
      Trains::DTO::Method(name: 'destroy', visibility: nil, source: nil)
    ]
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/faraazahmad/trains. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/faraazahmad/trains/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Trains project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/faraazahmad/trains/blob/master/CODE_OF_CONDUCT.md).

