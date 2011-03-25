require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FileName do
  it "should return unchanged filename" do
    filename = FileName.new("abc.txt")
    filename.create.should == File.expand_path(File.dirname('.') + '/abc.txt')
  end

  it "should return new filename with number" do
    filename = FileName.new(__FILE__)
    path = filename.create
    File.exist?(path).should_not be_true
    path.should match(/\.\d+$/)
  end

  it "should return new filename with number with digit" do
    filename = FileName.new(__FILE__, :digit => 3, :position => :suffix)
    filename.create.should match(/\.000$/)
    filename.create.should match(/\.001$/)
  end

  it "should return new filename with specified number" do
    filename = FileName.new(__FILE__, :digit => 3, :position => :suffix, :start => 10)
    filename.create.should match(/\.010$/)
    filename.create.should match(/\.011$/)
  end

  it "should return new filename with specified delimiter" do
    filename = FileName.new(__FILE__, :digit => 2, :position => :suffix, :delimiter => '@')
    filename.create.should match(/@00$/)
  end

  it "should return new filename from format string of sprintf" do
    filename = FileName.new(__FILE__, :format => "ABC%dDEF")
    filename.create.should match(/ABC0DEF$/)
  end

  it "should return new filename from proc object" do
    filename = FileName.new(__FILE__, :start => 3, :format => lambda { |n| sprintf("%03d", n * n) })
    filename.create.should match(/\.009$/)
  end

  it "should raise error" do
    filename = FileName.new(__FILE__, :format => "")
    lambda do
      filename.create
    end.should raise_error
  end

  it "should return new filename with time" do
    filename = FileName.new(__FILE__, :type => :time)
    path = filename.create
    File.exist?(path).should_not be_true
    path.should match(/\.[\d_]+$/)
  end

  it "should return new filename from format string of time" do
    filename = FileName.new(__FILE__, :type => :time, :format => "%Y")
    filename.create.should match(/\.\d{4}$/)
    lambda do
      filename.create
    end.should raise_error
  end

  it "should return new filename from proc object" do
    filename = FileName.new(__FILE__, :type => :time, :format => lambda { |t| t.strftime("%Y_%Y") })
    filename.create.should match(/\.\d\d\d\d_\d\d\d\d$/)
  end

  it "should return same filename" do
    filename = FileName.new(__FILE__)
    path = filename.create(:add => :prohibit)
    path.should == File.expand_path(__FILE__)
  end

  it "should return same filename" do
    file = File.join(__FILE__, 'not_exist')
    filename = FileName.new(file)
    path = filename.create
    path.should == file
  end

  it "should return filename with additional part" do
    file = File.join(__FILE__, 'not_exist')
    filename = FileName.new(file)
    path = filename.create(:add => :always)
    path.should_not == file
  end

  it "should return filename with prefix" do
    filename = FileName.new(__FILE__, :position => :prefix)
    path = filename.create
    dir, name = File.split(path)
    name.should match(/^\d+_/)
  end

  it "should return filename with addition before extension" do
    filename = FileName.new(__FILE__, :position => :middle)
    path = filename.create
    dir, name = File.split(path)
    ext = File.extname(name)
    name.should match(Regexp.new("_\\d+\\#{ext}"))
  end

  it "should create parent directory" do
    basename = File.join(File.dirname(__FILE__), 'abc/def')
    filename = FileName.new(basename)
    path = filename.create(:directory => true)
    dir = File.dirname(basename)
    File.exist?(dir).should be_true
    Dir.rmdir(dir)
  end

end
