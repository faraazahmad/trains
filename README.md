# Trains

Extract information about your Rails app using static analysis.

(WIP)

## Example

You can run the CLI by executing main.rb and providing a path to a Rails app directory:

```bash
$ ruby main.rb ~/oss/sample-proj/
```

It will give you a result with all the models and controllers in your app:

```ruby
[#<Model:0x000055dc0fdd60f8
  @fields=
   [{:column=>:created_at, :type=>:datetime},
    {:column=>:updated_at, :type=>:datetime}],
  @name=:boxes>,
 #<Model:0x000055dc10129250
  @fields=
   [{:column=>:flavor, :type=>:string},
    {:column=>:box, :type=>:reference},
    {:column=>:created_at, :type=>:datetime},
    {:column=>:updated_at, :type=>:datetime}],
  @name=:chocolates>]
[#<Controller:0x000055dc0fe4cdc0
  @controller_methods=#<Set: {}>,
  @name=:ApplicationController>,
 #<Controller:0x000055dc0fe3fbc0
  @controller_methods=#<Set: {:new, :create, :edit, :delete}>,
  @name=:BoxController>]
```
