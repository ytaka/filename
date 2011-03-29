require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FileName do
  def check_create_directory(filename, basename, path)
    dir = File.dirname(basename)
    File.exist?(dir).should be_true
    Dir.rmdir(dir)
  end

  NOT_EXIST_FILE_PATH = 'abc.txt'

  it "should return unchanged filename" do
    filename = FileName.new(NOT_EXIST_FILE_PATH)
    filename.create.should == File.expand_path(File.dirname('.') + '/' + NOT_EXIST_FILE_PATH)
  end

  it "should return unchanged filename with relative path" do
    filename = FileName.new("abc.txt", :add => :auto, :path => :relative)
    filename.create.should == NOT_EXIST_FILE_PATH
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

  it "should change extension" do
    filename = FileName.new(__FILE__)
    path = filename.create(:add => :prohibit, :extension => 'txt')
    path.should_not == __FILE__
    path.should match(/\.txt$/)
  end

  it "should create parent directory" do
    basename = File.join(File.dirname(__FILE__), 'abc/def')
    filename = FileName.new(basename)
    path = filename.create(:directory => true)
    check_create_directory(filename, basename, path)
  end

  context "when we set the default options of FileName#create" do
    NUMBER_TEST_REPEAT = 3
    
    it "should prohibit addition" do
      filename = FileName.new(__FILE__, :add => :prohibit)
      NUMBER_TEST_REPEAT.times do |i|
        filename.create.should == __FILE__
      end
    end

    it "should add always" do
      filename = FileName.new(__FILE__, :add => :always)
      NUMBER_TEST_REPEAT.times do |i|
        filename.create.should_not == __FILE__
      end
    end

    it "should add automatically" do
      filename = FileName.new(__FILE__, :add => :auto)
      NUMBER_TEST_REPEAT.times do |i|
        filename.create.should_not == __FILE__
      end
    end

    it "should return as it is" do
      name_not_exit = __FILE__ + Time.now.to_i.to_s
      filename = FileName.new(name_not_exit, :add => :auto)
      NUMBER_TEST_REPEAT.times do |i|
        filename.create.should == name_not_exit
      end
    end

    it "should create parent directory" do
      basename = File.join(File.dirname(__FILE__), 'abc/def')
      filename = FileName.new(basename, :directory => true)
      NUMBER_TEST_REPEAT.times do |i|
        path = filename.create
        check_create_directory(filename, basename, path)
      end
    end

    it "should change extension" do
      filename = FileName.new(__FILE__, :extension => 'txt', :add => :prohibit)
      NUMBER_TEST_REPEAT.times do |i|
        path = filename.create
        path.should_not == __FILE__
        path.should match(/\.txt$/)
      end
    end
  end

end
