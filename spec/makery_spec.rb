require 'makery'
require 'ostruct'

RSpec.describe Makery do
  it "has a version number" do
    expect(Makery::VERSION).not_to be nil
  end

  it "does something useful" do
    Makery.for(OpenStruct) do |maker|
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
        assn: ->(m) { OpenStruct.make(name: "#{m[:name]} bob", assn: m.obj) }
      )
    end

    expect(OpenStruct.make.name).to eq('bob')
    expect(OpenStruct.make.role).to eq('guest')

    expect(OpenStruct.make(:admin).name).to eq('bob')
    expect(OpenStruct.make(:admin).role).to eq('admin')

    expect(OpenStruct.make(name: 'joe').name).to eq('joe')

    expect(OpenStruct.make(:delayed_name).name).to eq('del')

    expect(OpenStruct.make(:admin, name: 'joe').name).to eq('joe')
    expect(OpenStruct.make(:admin, name: 'joe').role).to eq('admin')

    expect(OpenStruct.make(:admin, :joe).name).to eq('joe')
    expect(OpenStruct.make(:admin, :joe).role).to eq('admin')

    expect(OpenStruct.make(name: ->(m) { m[:role] + ' joe' }).name).to eq('guest joe')

    expect(
      OpenStruct.make(:with_assn).assn.name
    ).to eq(
      'bob bob'
    )

    expect(
      OpenStruct.make(:delayed_name, :with_assn).assn.name
    ).to eq(
      'del bob'
    )

    o = OpenStruct.make(:with_assn)
    expect(
      o.assn.assn
    ).to eq(
      o
    )
  end
end
