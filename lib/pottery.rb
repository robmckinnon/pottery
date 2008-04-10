require 'morph'
require 'soup'

# require 'ruby2ruby'
# class Example; include Pottery; end
# e = Example.new
# e.noise = 'blue'
# puts RubyToRuby.translate(Example)
module Pottery
  VERSION = "0.1.0"

  def self.included(base)
    Soup.prepare
    base.send(:include, Morph::InstanceMethods)
    base.extend Morph::ClassMethods
    base.send(:include, InstanceMethods)
  end

  class PotterySnip < Snip
    def get_value(name)
      super
    end

    def set_value(name, value)
      super
    end
  end

  module InstanceMethods

    def method_missing symbol, *args
      is_writer = symbol.to_s =~ /=\Z/
      if is_writer
        morph_method_missing symbol, *args do |base, attribute|
          # alternative 1:
          # base.class_eval "def #{attribute}; @snip.get_value('#{attribute}') ; end"
          # base.class_eval "def #{attribute}= value; @snip ||= Pottery::PotterySnip.new; @snip.set_value('#{attribute}', value) ; end"

          # alternative 2:
          # base.class_eval { define_method(attribute) { @snip.get_value(attribute) } }
          # base.class_eval do
            # define_method("#{attribute}=") do |value|
              # @snip ||= Pottery::PotterySnip.new
              # @snip.set_value(attribute, value)
            # end
          # end

          # alternative 3:
          base.class_def(attribute) { @snip.get_value(attribute) }
          base.class_def("#{attribute}=") do |value|
            @snip ||= Pottery::PotterySnip.new
            @snip.set_value(attribute, value)
          end
        end
        send(symbol, *args)
      else
        super
      end
    end
  end

end
