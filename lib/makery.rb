require 'makery/version'

# do factory stuff
module Makery
  def self.[](klass)
    makers[klass]
  end

  def self.makers
    @makers ||= new_makers
  end

  def self.new_makers
    Hash.new { |h, k| h[k] = Factory.new(k) }
  end

  module DSL
  end

  # makes stuff
  Factory = Struct.new(:klass) do

    def call(*traits, **override)
      Builder.call(base.merge(**trait_attrs(traits), **override), klass, :new)
    end

    def base(**attrs)
      @base ||= attrs
    end

    def instantiation_method(method = :new)
      @instantiation_method = method
    end

    def trait_attrs(traits)
      traits.map { |t| traits_repository[t] }.reduce({}, &:merge)
    end

    def trait(name, **attrs)
      traits_repository[name] = attrs
    end

    def traits_repository
      @traits ||= {}
    end

  end

  # makes stuff
  Builder = Struct.new(:attrs, :klass, :instantiation_method) do
    attr_reader :obj
    def self.call(*args)
      new(*args).call
    end

    def call
      @obj = klass.send(instantiation_method)
      transform
      @obj
    end

    def transform
      attrs.each { |k, v| attrs[k] = (v.respond_to?(:call) ? v.call(self) : v) }
      attrs.each { |k, v| @obj.send("#{k}=", v) }
    end

    def [](attr)
      a = attrs[attr]
      a.respond_to?(:call) ? a.call(self) : a
    end
  end
end
