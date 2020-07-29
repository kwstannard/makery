# Makery [![Build Status](https://travis-ci.org/kwstannard/makery.svg?branch=master)](https://travis-ci.org/kwstannard/makery)

Welcome to Makery. Your [simple, lightweight, opinionated, elegant, minimal](https://programmingisterrible.com/post/65781074112/devils-dictionary-of-programming)
choice for testing factories.

## Why Makery and not FactoryBot?

### ORM independence

Makery is completely ORM independent. You can use it easily with any complex data object and no special flags needed.

### Instantialize your object relationship graph without hitting the database

You can use Makery's delayed execution blocks to create arbitrarily complex relationships without costly database
transactions. This allows you to run tests and order of magnitude faster than equivalent tests using FactoryBot.

### Small

Makery is 69 lines of code, a 96% reduction over FactoryBot

### Speed

When just initializing objects, Makery is a 10x-30x speed improvement over FactoryBot. Makery also allows you to
easily set up relationships between objects without using the database, which is another order of magnitude
speed boost if you are testing business logic. Run `bundle exec ruby benchmark.rb` and look at `benchmark.rb`
for more details.

## Installation

```shell
echo "gem 'makery'" >> Gemfile
bundle
```

## Usage

### Defining a factory

Makery leverages named arguments everywhere to avoid use of DSLs. Create or fetch a factory using `Makery[YourClass]`.
Then set the base attributes with `#base(attr_hash)`

```ruby
class Post
  attr_accessor :foo, :bar
end

maker = Makery[Post]
maker.base(
  foo: 1,
  bar: 2
)
```

```ruby
klass = Struct.new(:foo, :bar)

maker = Makery[klass]
maker.base(
  foo: 1
  bar: 2
)
```

```ruby
class User < ActiveRecord::Base
end

Makery[User].base(
  email: "foo@bar.com",
)
```

#### Using the factory

Use `#call` to create a new object of your class.

```ruby
post = Makery[Post].call
post.foo #=> 1

obj = Makery[klass].call
obj.foo #=> 1

Makery[User].call.email == "foo@bar.com" #=> true
```

Makery uses anything that responds to `call` for delayed execution, usually a Proc. There is a
single argument passed for accessing the other attributes. You can also pass
overrides into the call to maker.

```ruby
Makery[klass].call(foo: ->(m) { m[:bar] + 1 }).foo == 3 #=> true
```

Makery uses traits to allow further specification of a class. Traits are merged over
the base attributes.

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
  email: ->(m) { "user-#{m.id}@biz.com" }
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

Makery operates independently of ActiveRecord or any ORM. You could do one of the
following.

```ruby
maker = Makery[User]
maker.base(
  email: "email@email.com"
  password: "a password"
)

user = Makery[User].call
user.save

# or a method to handle it like FactoryBot

def create(klass, *args)
  Makery[klass].call(*args).tap(&:save)
end
create(User)
```

### Custom Factories

A way to make custom factories has been provided via the `#[]=` method. Anything can be stored,
but you probably want to use a proc. The following example uses a proc with default arguments to
create a JSON document.

```ruby
Makery["user registration request body"] = ->(username: 'joe', password: '1234') {
  {user: {username: username, password: password} }.to_json
}

Makery["user registration request body"].call
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
