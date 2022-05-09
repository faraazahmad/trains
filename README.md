# Trains

Extract information about your Rails app using static analysis.

(WIP)

## Features

Trains can currently achieve the following:

- [x] Generate model definitions from your DB migrations
- [x] Generate controllers definitions and list their methods
- [ ] Generate a list of all helpers created
- [ ] List out all the included helpers with a controller's view
- [ ] Merge multiple DB migrations to create a single Model definition
- [ ] Merge Rails::Model definition with a Trains Model definition
- [ ] Be more robust in handling different types and syntax of Migrations, models, controllers etc.

## Example

You can run the CLI by executing main.rb and providing a path to a Rails app directory:

```bash
$ ruby main.rb ~/oss/sample-proj/
```

It will give you a result with all the models and controllers in your app:

```ruby
#<Trains:0x0000556a1f009a40
 @controllers=
  [#<Controller:0x0000556a1f0cb668
    @controller_methods=#<Set: {}>,
    @name=:ApplicationController>,
   #<Controller:0x0000556a1f0c2518
    @controller_methods=#<Set: {:new, :create, :edit, :delete}>,
    @name=:BoxController>],
 @dir=#<Dir:/home/faraaz/oss/sample-proj>,
 @folder=#<Dir:/home/faraaz/oss/sample-proj>,
 @helpers=[],
 @models=
  [#<Model:0x0000556a1ee4b898
    @fields=
     [{:column=>:created_at, :type=>:datetime},
      {:column=>:updated_at, :type=>:datetime}],
    @name=:boxes>,
   #<Model:0x0000556a1f2bbdb0
    @fields=
     [{:column=>:flavor, :type=>:string},
      {:column=>:box, :type=>:reference},
      {:column=>:created_at, :type=>:datetime},
      {:column=>:updated_at, :type=>:datetime}],
    @name=:chocolates>],
 @nodes=
  {:path=>"/home/faraaz/oss/sample-proj",
   :children=>[...]
   }>
```
