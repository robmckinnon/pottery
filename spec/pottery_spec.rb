require File.dirname(__FILE__) + '/../lib/pottery'
require File.dirname(__FILE__) + '/pottery_spec_helper'

describe Pottery, "when writer method that didn't exist before is called with non-nil value" do
  include PotterySpecHelperMethods

  before :each do
    remove_morph_methods
    @quack = 'quack'
    @pottery.noise= @quack
    @attribute = 'noise'
    @expected_morph_methods_count = 2
  end

  it_should_behave_like "class with generated accessor methods added"

  it 'should return assigned value when reader method called' do
    @pottery.noise.should == @quack
  end
end

describe Pottery, "when pottery class is loaded" do
  include PotterySpecHelperMethods

  it 'should call Soup.prepare to setup database' do
    Soup.should_receive(:prepare)
    initialize_pottery_class
  end

  it 'should add restore class method' do
    initialize_pottery_class
    @potted_class.respond_to?('restore').should be_true
  end
end

describe Pottery, "when reader method that doesn't exist is called" do
  include PotterySpecHelperMethods

  it 'should set attribute and value on the Snip instance' do
    initialize_pottery_and_snip
    lambda { @pottery.noise }.should raise_error(/undefined method `noise'/)
  end
end


describe Pottery, "when save method is called after name has been set" do
  include PotterySpecHelperMethods

  after :each do remove_morph_methods; end

  it 'should call save on the Snip instance' do
    initialize_pottery_and_snip
    @pottery.name = 'red'
    @snip.should_receive(:save)
    @pottery.save
  end

  it 'should call set_value on the Snip instance with attribute and value' do
    initialize_pottery_and_snip
    @pottery.name = 'red'

    @snip.stub!(:save)
    @snip.should_receive(:set_value).with('name', 'red')
    @pottery.save
  end
end


describe Pottery, "when save method is called after name has not been set" do
  include PotterySpecHelperMethods

  after :all do remove_morph_methods; end

  it 'should call save on the Snip instance' do
    initialize_pottery_and_snip
    @pottery.colour = 'red'
    lambda { @pottery.save }.should raise_error(/unique name must be defined/)
  end
end

describe Pottery, "when restore method is called with name on class" do
  include PotterySpecHelperMethods

  before :each do
    initialize_pottery_and_snip
    @snip = mock(Pottery::PotterySnip)
    @snip.stub!(:attributes).and_return({})
    Pottery::PotterySnip.stub!('[]'.to_sym).and_return @snip
  end

  it 'should call Snip [] load method with given name' do
    name = 'red'
    Pottery::PotterySnip.should_receive('[]'.to_sym).with(name).and_return nil
    @potted_class.restore(name)
  end

  it 'should return an instance of the class if Snip [] returns not nil' do
    @potted_class.restore('red').should be_an_instance_of(@potted_class)
  end

  it 'should return nil if Snip [] returns nil' do
    Pottery::PotterySnip.stub!('[]'.to_sym).and_return nil
    @potted_class.restore('red').should be_nil
  end

  it 'should set attributes from snip on to class instance and return instance' do
    attributes = {:name => 'red', :state => 'blue'}

    @snip.stub!(:attributes).and_return(attributes)
    Pottery::PotterySnip.stub!('[]'.to_sym).and_return @snip
    instance = mock(@potted_class)
    @potted_class.stub!(:new).and_return instance

    instance.should_receive(:morph).with(attributes)
    @potted_class.restore('red').should == instance
  end

end

