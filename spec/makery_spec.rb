require 'makery'

RSpec.describe Makery do
  it "has a version number" do
    expect(Makery::VERSION).not_to be nil
  end

  it "does something useful" do
    klass = Struct.new(:name, :role, :assn)
    makery = Makery.dup

    makery.for(klass) do |maker|
      maker.base(
        name: 'bob',
        role: 'guest'
      )

      maker.instantiation_method(:new)

      maker.trait(
        :admin,
        role: 'admin'
      )

      maker.trait(
        :joe,
        name: 'joe'
      )

      maker.trait(
        :delayed_name,
        name: proc { 'del' }
      )

      maker.trait(
        :with_assn,
        assn: ->(m) { makery[klass].call(name: "#{m[:name]} bob", assn: m.obj) }
      )
    end

    expect(makery[klass].call.name).to eq('bob')
    expect(makery[klass].call.role).to eq('guest')

    expect(makery[klass].call(:admin).name).to eq('bob')
    expect(makery[klass].call(:admin).role).to eq('admin')

    expect(makery[klass].call(name: 'joe').name).to eq('joe')

    expect(makery[klass].call(:delayed_name).name).to eq('del')

    expect(makery[klass].call(:admin, name: 'joe').name).to eq('joe')
    expect(makery[klass].call(:admin, name: 'joe').role).to eq('admin')

    expect(makery[klass].call(:admin, :joe).name).to eq('joe')
    expect(makery[klass].call(:admin, :joe).role).to eq('admin')

    expect(makery[klass].call(name: ->(m) { m[:role] + ' joe' }).name).to eq('guest joe')

    expect(
      makery[klass].call(:with_assn).assn.name
    ).to eq(
      'bob bob'
    )

    expect(
      makery[klass].call(:delayed_name, :with_assn).assn.name
    ).to eq(
      'del bob'
    )

    o = makery[klass].call(:with_assn)
    expect(
      o.assn.assn
    ).to eq(
      o
    )
  end
end
