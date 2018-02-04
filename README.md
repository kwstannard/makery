# Makery [![Build Status](https://travis-ci.org/kwstannard/makery.svg?branch=master)](https://travis-ci.org/kwstannard/makery)

Welcome to Makery. Your [simple, lightweight, opinionated, elegant, minimal](https://programmingisterrible.com/post/65781074112/devils-dictionary-of-programming)
choice for testing factories.

## Installation

```shell
echo "gem 'makery'" >> Gemfile
bundle
```

## Usage

### What kinds of classes can use this?

Any class needs writer methods corresponding to each attribute and that should be it.

### Defining a factory

* Makery tries to avoid DSLs.

```ruby
klass = Struct.new(:foo, :bar)

Makery.for(klass) do |maker|
  maker.base(
    foo: 1
    bar: 2
  )
end

Makery[klass].call.foo == 1 #=> true
```

* Makery uses anything that responds to call to execute delayed.
* Pass overrides into the call to maker.

```ruby
Makery[klass].call(foo: ->(m) { m[:bar] + 1 }).foo == 3 #=> true
```

* Makery uses traits for more complex behavior.

```ruby
Makery.for(klass) do |maker|
  maker.base(
    foo: 1
    bar: 2
  )

  maker.trait(
    :big_foo,
    foo: 10
  )
end

Makery[klass].call(:big_foo).foo == 10 #=> true
```

### ActiveRecord

This operates independently of ActiveRecord or any ORM. Just call save if you need to create the record in the database.

### That is too long

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kwstannard/makery. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Makery project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/kwstannard/makery/blob/master/CODE_OF_CONDUCT.md).
