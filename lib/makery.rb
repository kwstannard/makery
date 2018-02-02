require 'makery/version'

# do factory stuff
module Makery
  def self.for(klass)
    klass.define_singleton_method(:make) do |*traits, **override|
      Makery.makers[klass].make(*traits, **override)
    end

    yield makers[klass]
  end

  def self.makers
    @makers ||= new_makers
  end

  def self.new_makers
    Hash.new { |h, k| h[k] = Maker.new(k) }
  end

  # makes stuff
  Maker = Struct.new(:klass) do

    def make(*traits, **override)
      attrs = to_attrs(*traits).merge(override)
      attrs = attrs.transform_values { |v| v.respond_to?(:call) ? v.call(attrs) : v }

      klass.new(attrs)
    end

    def base(**attrs)
      @base ||= attrs
    end

    def trait(name, **attrs)
      traits_repository[name] = attrs
    end

    def traits_repository
      @traits ||= {}
    end

    def to_attrs(*traits)
      merged_traits = traits.map { |t| traits_repository[t] }.reduce({}, &:merge)
      base.merge(merged_traits)
    end
  end
end
