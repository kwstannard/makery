require "makery"

RSpec.describe Makery do
  let(:makery) { described_class.dup }
  let(:klass) { Struct.new(:name, :role, :association) }
  let(:maker) { makery[klass] }

  before do
    maker.base(
      name: "bob",
      role: "guest"
    )

    maker.trait(
      :admin,
      role: "admin"
    )

    maker.trait(
      :joe,
      name: "joe"
    )

    maker.trait(
      :delayed_name,
      name: proc { "del" }
    )

    maker.trait(
      :with_association,
      association: lambda do |m|
        makery[klass].call(name: "#{m[:name]} bob", association: m.obj)
      end
    )
  end

  it "has a version number" do
    expect(described_class::VERSION).not_to be nil
  end

  it "uses the base attributes if nothing else is specified" do
    expect(makery[klass].call.name).to eq("bob")
    expect(makery[klass].call.role).to eq("guest")
  end

  it "overrides the base with any requested trait attributes" do
    expect(makery[klass].call(:admin).name).to eq("bob")
    expect(makery[klass].call(:admin).role).to eq("admin")
  end

  it "uses K:V arguments as a final override" do
    expect(makery[klass].call(name: "joe").name).to eq("joe")
  end

  it "objects that respond to call will be executed and the return used" do
    expect(makery[klass].call(:delayed_name).name).to eq("del")
  end

  it "overrides traits with K:V args" do
    expect(makery[klass].call(:admin, name: "joe").name).to eq("joe")
    expect(makery[klass].call(:admin, name: "joe").role).to eq("admin")
  end

  it "overrides attributes with traits in called order" do
    expect(makery[klass].call(:admin, :joe).name).to eq("joe")
    expect(makery[klass].call(:admin, :joe).role).to eq("admin")
    expect(makery[klass].call(:delayed_name, :joe).name).to eq("joe")
  end

  it "sends the builder as the first argument to call" do
    expect(
      makery[klass].call(name: ->(m) { m[:role] + " joe" }).name
    ).to eq("guest joe")
  end

  it "the builder's obj can be used for associations" do
    expect(
      makery[klass].call(:with_association).association.name
    ).to eq("bob bob")

    expect(
      makery[klass].call(:delayed_name, :with_association).association.name
    ).to eq("del bob")

    o = makery[klass].call(:with_association)
    expect(o.association.association).to eq(o)
  end

  it "allows use of associations within other factories" do
    makery[klass].trait(
      :use_association,
      name: ->(m) { "#{m[:association].name} rob" },
      association: ->(m) { makery[klass].call(association: m.obj) }
    )

    expect(makery[klass].call(:use_association).name).to eq("bob rob")
  end

  it "has sequences" do
    expect(
      makery[klass].call(name: ->(m) { "user#{m.id}" }).name
    ).to eq("user1")
    expect(
      makery[klass].call(name: ->(m) { "user#{m.id}" }).name
    ).to eq("user2")
  end

  it "allows custom fatories" do
    makery[:custom] = ->(attrs) { attrs }
    expect(makery[:custom].call(foo: 1)).to eq(foo: 1)
  end

  context "when the class doesn't respond to the instantiation method" do
    it "throws a useful error" do
      expect { makery[Module.new].call }.to raise_error(NoMethodError)
    end
  end
end
