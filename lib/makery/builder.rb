# frozen_string_literal: true

class Object; def makery_eval(_); self; end; end
Proc.alias_method(:makery_eval, :call)

module Makery
  # Builder builds the instance
  Builder = Struct.new(:attrs, :object, :id) do

    def self.call(*args)
      new(*args).call
    end

    def call
      attrs.each_key { |k| evaluate_attr(k) }
      object
    end

    def evaluate_attr(attr)
      val = attrs[attr].makery_eval(self)
      object.send("#{attr}=", val)
    end
    alias_method :[], :evaluate_attr
  end
end
