# frozen_string_literal: true

module Makery
  using(Module.new do
    refine(Object) { define_method(:makery_eval) { |_| self } }
    refine(Proc) { alias_method(:makery_eval, :call) }
  end)

  # Builder builds the instance
  Builder = Struct.new(:attrs, :object, :i) do
    def self.call(*args)
      new(*args).call
    end

    def call
      attrs.each_key { |k| evaluate_attr(k) }
    end

    def evaluate_attr(attr)
      object.send("#{attr}=", attrs[attr].makery_eval(self))
    end
    alias_method :[], :evaluate_attr
  end
end
