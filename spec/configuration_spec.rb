require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FileName do
  context "when saving example of configuration" do
    before(:all) do
      @dir = File.join(File.dirname(__FILE__), 'conf.tmp')
      FileName::Manage.class_variable_set(:@@filename_directory, @dir)
    end

    it "should create directory" do
      FileName::Manage.new.save_configuration_example
      File.exist?(@dir).should be_true
      conf_dir = File.join(@dir, FileName::Manage::CONF_DIRECTORY)
      File.exist?(conf_dir).should be_true
      Dir.entries(conf_dir).should include(FileName::Manage::SAMPLE_CONF_NAME)
    end

    after(:all) do
      FileUtils.rm_r(@dir) if File.exist?(@dir)
    end
  end

  context "when loading configuration" do
    before(:all) do
      @dir = File.join(File.dirname(__FILE__), 'conf.tmp')
      FileName::Manage.class_variable_set(:@@filename_directory, @dir)
      FileName::Manage.new.save_configuration_example
      path = File.join(@dir, FileName::Manage::CONF_DIRECTORY, FileName::Manage::SAMPLE_CONF_NAME)
      FileUtils.mv(path, path.sub(/\.example$/, ''))
      @conf = File.basename(path.sub(/\.rb\.example$/, ''))
    end

    it "should return FileName" do
      FileName.configuration(@conf, 'base.path').should be_an_instance_of(FileName)
    end

    it "should return key" do
      FileName.configuration(@conf, 'base.path').configuration_key.should == @conf
    end

    it "should dump and load" do
      s = FileName.configuration(@conf, 'base.path').dump
      s.should be_an_instance_of String
      FileName.load(s).should be_an_instance_of FileName
    end

    it "should return nil" do
      FileName.configuration(:not_exist, 'base.path').should be_nil
    end

    after(:all) do
      FileUtils.rm_r(@dir) if File.exist?(@dir)
    end
  end
end
