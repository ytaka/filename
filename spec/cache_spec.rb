require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FileName do
  before(:all) do
    @filename = FileName.new('abc', 'def.txt')
  end

  it "should dump and load" do
    s = @filename.dump
    s.should be_an_instance_of String
    FileName.load(s).should be_an_instance_of FileName
  end

  it "should dump and load" do
    s = FileName.new('abc', :data => { :a => 1 }).dump
    s.should be_an_instance_of String
    filename = FileName.load(s)
    filename.should be_an_instance_of FileName
    data = filename.instance_eval { @data }
    data.instance_variable_get(:@a).should == 1
  end

  it "should not be able to dump" do
    filename = FileName.new('abc', :format => lambda { |n| sprintf("%02d", n * n) })
    lambda do
      filename.dump
    end.should raise_error
  end
end
