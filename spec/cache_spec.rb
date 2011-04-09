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

  it "should not be able to dump" do
    filename = FileName.new('abc', :format => lambda { |n| sprintf("%02d", n * n) })
    lambda do
      filename.dump
    end.should raise_error
  end
end
