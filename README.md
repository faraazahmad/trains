# Trains

A gem that statically analyses your Rails app and extracts information about its structure.

## Installation

```sh
gem install trains
```

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
  name: 'CreateGroups',
  fields:
    Set[
      Trains::DTO::Field.new(:datetime, :created_at),
      Trains::DTO::Field.new(:datetime, :updated_at),
      Trains::DTO::Field.new(:string, :title)
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
  name: :BoxController,
  methods: Set[:create, :edit, :update, :destroy]
)
```
