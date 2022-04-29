# Trains

Intelligent autocomplete about your rails app that is context aware. Built using static analysis.

(WIP)

## Example

```
~/oss/trains$ ruby main.rb ~/oss/sample-proj/
---
- !ruby/object:Model
  name: :boxes
  fields:
  - :column: :created_at
    :type: :datetime
  - :column: :updated_at
    :type: :datetime
- !ruby/object:Model
  name: :chocolates
  fields:
  - :column: :flavor
    :type: :string
  - :column: :box
    :type: :reference
  - :column: :created_at
    :type: :datetime
  - :column: :updated_at
    :type: :datetime
```

Shows the models (in YAML format) and their fields by parsing the db migrations
