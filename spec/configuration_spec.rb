require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FileName do
  context "when saving example of configuration" do
    before(:all) do
      @dir = File.join(File.dirname(__FILE__), 'conf.tmp')
      FileName.class_variable_set(:@@filename_directory, @dir)
    end

    it "should create directory" do
      FileName.save_configuration_example
      File.exist?(@dir).should be_true
      conf_dir = File.join(@dir, FileName::CONF_DIRECTORY)
      File.exist?(conf_dir).should be_true
      Dir.entries(conf_dir).should include(FileName::SAMPLE_CONF_NAME)
    end

    after(:all) do
      FileUtils.rm_r(@dir) if File.exist?(@dir)
    end
  end

  context "when loading configuration" do
    before(:all) do
      @dir = File.join(File.dirname(__FILE__), 'conf.tmp')
      FileName.class_variable_set(:@@filename_directory, @dir)
      FileName.save_configuration_example
      path = File.join(@dir, FileName::CONF_DIRECTORY, FileName::SAMPLE_CONF_NAME)
      FileUtils.mv(path, path.sub(/\.example$/, ''))
      @conf = File.basename(path.sub(/\.rb\.example$/, ''))
    end

    it "should return FileName" do
      FileName.configuration(@conf, 'base.path').should be_an_instance_of(FileName)
    end

    it "should return nil" do
      FileName.configuration(:not_exist, 'base.path').should be_nil
    end

    after(:all) do
      FileUtils.rm_r(@dir) if File.exist?(@dir)
    end
  end
end
