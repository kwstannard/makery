require "makery/version"
require "makery/factory"

# The main interface to the factories.
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

end
