# frozen_string_literal: true

module Makery
  # Builder builds the instance
  Builder = Struct.new(:attrs, :klass, :instantiation_method, :id) do
    attr_accessor :object, :evaluated_attrs
    def self.call(*args)
      new(*args).call
    end

    def call
      self.object = klass.send(instantiation_method)
      self.evaluated_attrs = {}

      evaluate_delayed_attrs
      set_object_attributes
      object
    end

    def evaluate_delayed_attrs
      attrs.each_key { |k| evaluate_attr(k) }
    end

    def set_object_attributes
      evaluated_attrs.each { |k, v| object.send("#{k}=", v) }
    end

    def evaluate_attr(attr)
      possible_val = attrs[attr]
      evaluated_attrs[attr] = possible_val.respond_to?(:call) ? possible_val.call(self) : possible_val
    end
    alias_method :[], :evaluate_attr
  end
end
