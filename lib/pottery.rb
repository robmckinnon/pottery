require 'morph'
require 'soup'

module Pottery
  VERSION = "0.1.0"

  def self.included(base)
    Soup.prepare
    base.extend Pottery::ClassMethods, Morph::ClassMethods
    base.send(:include, Morph::InstanceMethods)
    base.send(:include, Morph::MethodMissing)
    base.send(:include, InstanceMethods)
  end

  class PotterySnip < Snip
    def set_value(name, value); super; end
  end

  module ClassMethods
    def restore name
      snip = Pottery::PotterySnip[name]
      if snip
        instance = self.new
        attributes = snip.attributes
        unless attributes.empty?
          id_name = attributes.delete('name')
          name = attributes.delete('name_name')
          attributes['id_name'] = id_name if id_name
          attributes['name'] = name if name
          instance.morph attributes
        end
        instance
      else
        nil
      end
    end
  end

  module InstanceMethods

    def save
      if respond_to?('id_name') && !id_name.nil? && !(id_name.to_s.strip.size == 0)
        snip = Pottery::PotterySnip.new
        morph_attributes.each_pair do |symbol, value|
          symbol = convert_if_name_or_id_name(symbol)
          snip.set_value(symbol.to_s, value)
        end
        snip.save
        self
      else
        raise 'unique id_name must be defined'
      end
    end

    private

    def convert_if_name_or_id_name(symbol)
      case symbol
        when :id_name
          :name
        when :name
          :name_name
        else
          symbol
      end
    end
=begin
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
          base.class_def(attribute) do
            @snip.get_value(attribute)
          end
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
=end
  end
end
