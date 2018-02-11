# Makery [![Build Status](https://travis-ci.org/kwstannard/makery.svg?branch=master)](https://travis-ci.org/kwstannard/makery)

Welcome to Makery. Your [simple, lightweight, opinionated, elegant, minimal](https://programmingisterrible.com/post/65781074112/devils-dictionary-of-programming)
choice for testing factories.

## Installation

```shell
echo "gem 'makery'" >> Gemfile
bundle
```

## Usage

### Defining a factory

Makery leverages named arguments everywhere to avoid use of DSLs.

```ruby
klass = Struct.new(:foo, :bar)

maker = Makery[klass]
maker.base(
  foo: 1
  bar: 2
)
```

#### Using the factory

```ruby
Makery[klass].call.foo == 1 #=> true
```

Makery uses anything that responds to `call` for delayed execution. There is a
single argument passed for accessing the other attributes. You can also pass
overrides into the call to maker.

```ruby
Makery[klass].call(foo: ->(m) { m[:bar] + 1 }).foo == 3 #=> true
```

Makery uses traits for more complex behavior. Attributes are overrridden by
merging the attribute hashes.

```ruby
maker = Makery[klass]
maker.base(
  foo: 1
  bar: 2
)

maker.trait(
  :big_foo,
  foo: 10
)

Makery[klass].call(:big_foo).foo == 10 #=> true
```

#### Sequences

```ruby
maker = Makery[User]
maker.base(
  email: ->(m) { "user-#{m.index}@biz.com" }
)

Makery[User].call.email #=> "user-1@biz.com"
Makery[User].call.email #=> "user-2@biz.com"
```

#### Associations

The object passed to call in delayed execuption provides an `obj` method for creating
associations between objects. Use it where you would pass the instance.

For example if you have a one to many association that could be described like so:

```ruby
boss = User.new
employee = User.new
boss.employees = [employee]
```

Makery could replicate it like this:

```ruby
maker = Makery[User]
maker.base(
  boss: ->(m) { Makery[User].call(employees: [m.obj]) }
)

employee = maker.call
boss = employee.boss
```

### What kinds of classes can use this?

Any class used needs writer methods corresponding to each attribute and that should be it.

### How does this work behind the scenes?

It is all about hashes and merging. The base attribute set is always there at the bottom and
each trait merges over the base. Finally the named arguments are merged over all of that. Once
that is merged, any attribute values that respond to `call` are called. Finally, an instance
of the class being factoried has its attributes set from the attribute hash.

### ActiveRecord and Sequel

Makery operates independently of ActiveRecord or any ORM. For now you could do one of the
following.

```ruby
maker = Makery[User]
maker.base(
  email: "email@email.com"
  password: "a password"
)

user = Makery[User].call
user.save

# or

user = Makery[User].call.tap(&:save)

# or

def create(klass, *args)
  Makery[klass].call(*args).tap(&:save)
end
create(User)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kwstannard/makery. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Makery project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/kwstannard/makery/blob/master/CODE_OF_CONDUCT.md).
