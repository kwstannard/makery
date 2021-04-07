# frozen_string_literal: true

require "makery/builder"

module Makery
  # The factory is the stucture that stores the parts for the builder.
  Factory = Struct.new(:klass) do
    attr_accessor :count, :traits_repository
    def initialize(*args)
      self.count = 0
      self.traits_repository = {}
      super
    end

    def call(*traits, **override)
      attrs = base.merge(**trait_attrs(traits), **override)
      self.count = count + 1
      klass.new.tap { |obj| Builder.call(attrs, obj, count) }
    end

    def base(**attrs)
      @base ||= attrs
    end

    def trait_attrs(traits)
      traits.map { |t| traits_repository[t] }.reduce({}, &:merge)
    end

    def trait(name, **attrs)
      traits_repository[name] = attrs
    end
  end
end
