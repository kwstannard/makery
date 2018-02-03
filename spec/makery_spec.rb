require 'makery'

RSpec.describe Makery do
  it "has a version number" do
    expect(Makery::VERSION).not_to be nil
  end

  it "does something useful" do
    klass = Struct.new(:name, :role, :assn)

    Makery.for(klass) do |maker|
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
        assn: ->(m) { klass.make(name: "#{m[:name]} bob", assn: m.obj) }
      )
    end

    expect(klass.make.name).to eq('bob')
    expect(klass.make.role).to eq('guest')

    expect(klass.make(:admin).name).to eq('bob')
    expect(klass.make(:admin).role).to eq('admin')

    expect(klass.make(name: 'joe').name).to eq('joe')

    expect(klass.make(:delayed_name).name).to eq('del')

    expect(klass.make(:admin, name: 'joe').name).to eq('joe')
    expect(klass.make(:admin, name: 'joe').role).to eq('admin')

    expect(klass.make(:admin, :joe).name).to eq('joe')
    expect(klass.make(:admin, :joe).role).to eq('admin')

    expect(klass.make(name: ->(m) { m[:role] + ' joe' }).name).to eq('guest joe')

    expect(
      klass.make(:with_assn).assn.name
    ).to eq(
      'bob bob'
    )

    expect(
      klass.make(:delayed_name, :with_assn).assn.name
    ).to eq(
      'del bob'
    )

    o = klass.make(:with_assn)
    expect(
      o.assn.assn
    ).to eq(
      o
    )
  end
end
