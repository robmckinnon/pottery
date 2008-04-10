require File.dirname(__FILE__) + '/../lib/pottery'

module PotterySpecHelperMethods

  def initialize_pottery_class
    @potted_class = eval 'class ExamplePottery; include Pottery; end'
  end

  def initialize_pottery
    Soup.stub!(:prepare)
    initialize_pottery_class
    @original_instance_methods = @potted_class.instance_methods
    @pottery = @potted_class.new
  end

  def initialize_snip
    @snip = mock(Snip)
    @snip.stub!(:set_value)
    Pottery::PotterySnip.stub!(:new).and_return @snip
  end

  def initialize_pottery_and_snip
    initialize_pottery
    initialize_snip
  end

  def remove_morph_methods
    @potted_class.instance_methods.each do |method|
      @potted_class.class_eval "remove_method :#{method}" unless @original_instance_methods.include?(method)
    end
  end

  def instance_methods
    @potted_class.instance_methods
  end

  def morph_methods
    @potted_class.morph_methods
  end

  def check_convert_to_pottery_method_name label, method_name
    initialize_pottery_class
    @potted_class.convert_to_pottery_method_name(label).should == method_name
  end

  def each_attribute
    if @attribute
      yield @attribute
    elsif @attributes
      @attributes.each {|a| yield a }
    end
  end
end

describe "class with generated accessor methods added", :shared => true do

  include PotterySpecHelperMethods
  before :all do initialize_pottery; end
  after  :all do remove_morph_methods; end

  it 'should add reader method to class instance_methods list' do
    each_attribute { |a| instance_methods.should include(a.to_s) }
  end

  it 'should add writer method to class instance_methods list' do
    each_attribute { |a| instance_methods.should include("#{a}=") }
  end

  it 'should add reader method to class morph_methods list' do
    each_attribute { |a| morph_methods.should include(a.to_s) }
  end

  it 'should add writer method to class morph_methods list' do
    each_attribute { |a| morph_methods.should include("#{a}=") }
  end

  it 'should only have generated accessor methods in morph_methods list' do
    morph_methods.size.should == @expected_morph_methods_count
  end

end

describe "class without generated accessor methods added", :shared => true do
  include PotterySpecHelperMethods

  before :all do
    initialize_pottery
  end

  after :all do
    remove_morph_methods
  end

  it 'should not add reader method to class instance_methods list' do
    instance_methods.should_not include(@attribute)
  end

  it 'should not add writer method to class instance_methods list' do
    instance_methods.should_not include("#{@attribute}=")
  end

  it 'should not add reader method to class morph_methods list' do
    morph_methods.should_not include(@attribute)
  end

  it 'should not add writer method to class morph_methods list' do
    morph_methods.should_not include("#{@attribute}=")
  end

  it 'should have empty morph_methods list' do
    morph_methods.size.should == 0
  end
end
