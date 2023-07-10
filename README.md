# RichEnums

With Enums we are able to map a label to a value on the database.
Use Rich Enum if you need to maintain an additional mapping at the point of enum definition,
for e.g. for presentation purposes or for mapping to a different value on a different system.

e.g. rich enum definition
```ruby
class User < ApplicationRecord
  # enum role: { admin: 1, user: 2 } # default enum definition
  rich_enum role: { admin: [1, 'ROLE001'], user: [2, 'ROLE101'] }, alt: 'code'
end

user = User.new(role: :admin)
user.role # => 'admin'
user.role_code # => 'ROLE001'
user.role_for_database # => 1
User.roles # => {"admin"=>1, "user"=>2}
User.role_codes # => {"admin"=>"ROLE001", "user"=>"ROLE101"}

```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rich_enums'
```

And then execute:

    $ bundle install

Or simply run 

    $ bundle add rich_enums
to add to Gemfile and run bundle install in one go.


## Usage
As shown in the example above, the rich_enum definition is similar to the default enum definition.
It simply augments the enum definition with an additional mapping.

The additional mapping can be named with the `alt` option. It defaults to 'alt_name' if unspecificed.
This comes in handy when you need to map to a different value on a different system.

1. Using rich_enum to define your enums provides you with an instance method (attribute name with a suffix specified with the alt property - defaults to _alt_name) to access the alternate value from the additional mapping.
2. It also provides you with a class method(attribute name with a plural suffix derived from the alt option - defaults to _alt_names) to access the additional mapping.


```ruby
class User < ApplicationRecord
  # enum role: { admin: 1, user: 2 } # default enum definition
  rich_enum role: { admin: [1, 'ROLE001'], user: [2, 'ROLE101'] } # if alt is not specified, it defaults to 'alt_name'
end

user = User.new(role: :admin)
user.role # => 'admin'
user.role_alt_name # => 'ROLE001'
user.role_for_database # => 1
User.roles # => {"admin"=>1, "user"=>2}
User.role_alt_names # => {"admin"=>"ROLE001", "user"=>"ROLE101"}
ExternalSystem.sync(user.external_id, role_code: user.role_alt_name)
```
Any arguments other than 'alt' are forwarded to the default enum definition.
For e.g. in this case _prefix: true is forwarded to the default enum definition.
```ruby
rich_enum payment_type: {
    upfront: [10, 'Full payment'],
    installment: [20, 'Pay in parts'],
}, _prefix: true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/betacraft/rich_enums. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/betacraft/rich_enums/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RichEnums project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rich_enums/blob/master/CODE_OF_CONDUCT.md).
