require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FileName do
  before(:all) do
    @filename = FileName.new('abc', 'def.txt', :format => lambda { |n| sprintf("%03d", n) })
  end

  it "should dump and load" do
    s = @filename.dump
    s.should be_an_instance_of String
    FileName.load(s).should be_an_instance_of FileName
  end

end
