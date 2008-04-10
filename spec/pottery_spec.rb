require File.dirname(__FILE__) + '/../lib/pottery'
require File.dirname(__FILE__) + '/pottery_spec_helper'

describe Pottery, "when writer method that didn't exist before is called with non-nil value" do
  include PotterySpecHelperMethods

  before :all do initialize_pottery; end
  after  :all do remove_morph_methods; end

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
end

describe Pottery, "when writer method that didn't exist before is called" do
  include PotterySpecHelperMethods

  before :each do initialize_pottery_and_snip; end
  after :each do remove_morph_methods; end

  it 'should create a Snip instance' do
    Pottery::PotterySnip.should_receive(:new).and_return @snip
    @pottery.skills = "Ruby"
  end

  it 'should set attribute and value on the Snip instance' do
    @snip.should_receive(:set_value).with('skills', 'Ruby')
    @pottery.skills = 'Ruby'
  end
end

describe Pottery, "after writer method has been called already" do
  include PotterySpecHelperMethods

  before :each do
    initialize_pottery_and_snip;
    @pottery.skills = "Ruby" # creates writer method
  end

  after :each do remove_morph_methods; end

  it 'should set attribute and value on the Snip instance on subsequent writer calls' do
    value = "Bowstaff, nunchuck"
    @snip.should_receive(:set_value).with('skills', value)
    @pottery.skills = value
  end

  it 'should get a value from the Snip instance on subsequent reader calls' do
    @snip.should_receive(:get_value).with('skills')
    @pottery.skills
  end
end


describe Pottery, "when reader method that doesn't exist is called" do
  include PotterySpecHelperMethods

  it 'should set attribute and value on the Snip instance' do
    initialize_pottery_and_snip
    lambda { @pottery.noise }.should raise_error(/undefined method `noise'/)
  end
end


describe Pottery, "when save method is called after a writer has been called" do
  include PotterySpecHelperMethods

  it 'should call save on the Snip instance' do
    initialize_pottery_and_snip
    @pottery.skills = 'Ruby'
    @snip.should_receive(:save)
    @pottery.save
    remove_morph_methods
  end
end
