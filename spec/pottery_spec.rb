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

describe Pottery, "when writer method that does exist before is called" do

  include PotterySpecHelperMethods
  before :each do initialize_pottery_and_snip; end
  after :each do remove_morph_methods; end

  it 'should set attribute and value on the Snip instance' do
    @pottery.skills = "Ruby" # creates writer method
    @value = "Bowstaff, nunchuck"
    @snip.should_receive(:set_value).with('skills', @value)
    @pottery.skills = @value
  end
end
