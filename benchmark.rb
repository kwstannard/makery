require 'factory_bot'
require 'makery'
require 'benchmark/ips'

foo = Struct.new(:bar)
delayed = Struct.new(:bar)

Makery[foo].base(
  bar: 1
)
Makery[foo].trait(
  :big,
  bar: 2
)

Makery[delayed].base(
  bar: ->(m) { 5 }
)

FactoryBot.factories.clear
FactoryBot.define do
  factory :foo, class: foo do
    bar 1

    trait :big do
      bar 2
    end
  end

  factory :delayed, class: delayed do
    bar { 5 }
  end
end

puts Makery[foo].call(:big)
puts Makery[foo].call(bar: 2)
puts Makery[foo].call(:big, bar: 3)
puts Makery[delayed].call

Benchmark.ips(quiet: true) do |rep|
  rep.report("control init + set") do
    foo.new.bar = 2
  end

  rep.report("makery base") do
    Makery[foo].call
  end

  rep.report("factory_bot base") do
    FactoryBot.build(:foo)
  end

  rep.compare!
end

Benchmark.ips(quiet: true) do |rep|
  rep.report("makery trait") do
    Makery[foo].call(:big)
  end

  rep.report("factory_bot trait") do
    FactoryBot.build(:foo, :big)
  end
  rep.compare!
end

Benchmark.ips(quiet: true) do |rep|
  rep.report("makery override") do
    Makery[foo].call(bar: 2)
  end

  rep.report("factory_bot override") do
    FactoryBot.build(:foo, bar: 2)
  end
  rep.compare!
end

Benchmark.ips(quiet: true) do |rep|
  rep.report("makery trait + override") do
    Makery[foo].call(:big, bar: 3)
  end

  rep.report("factory_bot trait + override") do
    FactoryBot.build(:foo, :big, bar: 3)
  end
  rep.compare!
end

Benchmark.ips(quiet: true) do |rep|
  rep.report("makery delayed") do
    Makery[delayed].call
  end

  rep.report("factory_bot delayed") do
    FactoryBot.build(:delayed)
  end
  rep.compare!
end
