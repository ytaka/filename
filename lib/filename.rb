require "filename/version"
autoload :FileUtils, 'fileutils'

# 
# The class to create filename that is not duplicated.
# We select type of additional part of filename: number or time.
# 
class FileName

  attr_accessor :configuration_key, :format

  OPTIONS_CREATE = [:extension, :add, :directory, :file]

  # The options are following:
  # 
  # [:start (Fixnum)]
  #  If ID string type is number, the ID starts from the specified number.
  # 
  # [:digit (Fixnum)]
  #  When we create additional part of a filename,
  #  we use a string of ID number with specified digit.
  # 
  # [:delimiter (String)]
  #  We use specified string for delimiter between base name and
  #  additional part. Default is '.' if position is suffix. Otherwise, '_'.
  # 
  # [:type (:number or :time)]
  #  We specify type of additional part: :number or :time.
  #  Default is :number.
  # 
  # [:format (String or Proc)]
  #  We specify format string of additional part or
  #  proc object to create additional part.
  #  If type is :time, the format string is used by Time#strftime.
  #  For :number type, the string is a farst argument of sprintf(format, number).
  #  Proc object takes an object of Time or Integer for respective types.
  # 
  # [:position (:prefix, :suffix, or :middle)]
  #  We specify of position of additional part of filename.
  # 
  # [:path]
  #  We sepecify if path created by FileName#create is absolute or relative.
  #  Default is absolute.
  # 
  # [:data]
  #  We specify hash expressing instance variables for evaluation of format proc,
  #  which is set by an option :format.
  #  If we set { :a => 1, :b => 2 } for :data option,
  #  we can use @a and @b in proc object set by :format option.
  # 
  # [:extension]
  #  Default value of the option of FileName#create.
  # 
  # [:add]
  #  Default value of the option of FileName#create.
  # 
  # [:directory]
  #  Default value of the option of FileName#create.
  # 
  # [:file]
  #  Default value of the option of FileName#create.
  def initialize(basepath, *rest)
    if Hash === rest[-1]
      opts = rest.delete_at(-1)
    else
      opts = {}
    end
    path = File.join(basepath, *rest)
    if opts[:path] == :relative
      @basepath = path
    else
      @basepath = File.expand_path(path)
    end
    @number = opts[:start] || 0
    @digit = opts[:digit] || 2
    if @digit < 1
      raise ArgumentError, "Number of digit must be positive."
    end
    @type = opts[:type] || :number
    @position = opts[:position] || :suffix
    @delimiter = opts[:delimiter] || (@position == :suffix ? '.' : '_')
    @format = opts[:format]
    @last_addition = nil
    @default_create = {}
    opts.each do |key, val|
      if OPTIONS_CREATE.include?(key)
        @default_create[key] = val
      end
    end
    @configuration_key = nil
    @data = Object.new
    if opts[:data]
      opts[:data].each do |key, val|
        @data.instance_variable_set("@#{key}", val)
      end
    end
  end

  def get_basepath(extension = nil)
    if extension
      extension = '.' + extension unless extension[0] == '.'
      oldext = File.extname(@basepath)
      if oldext.size > 0
        @basepath.sub(Regexp.new("\\#{oldext}$"), extension)
      else
        @basepath + extension
      end
    else
      @basepath
    end
  end
  private :get_basepath

  def create_time_addition(t)
    case @format
    when String
      t.strftime(@format)
    when Proc
      @data.instance_exec(t, &@format)
    else
      t.strftime("%Y%m%d_%H%M%S_") + sprintf("%06d", t.usec)
    end
  end
  private :create_time_addition

  def create_number_addition(number)
    case @format
    when String
      sprintf(@format, number)
    when Proc
      @data.instance_exec(number, &@format)
    else
      sprintf("%0#{@digit}d", number)  
    end
  end
  private :create_number_addition

  def get_addition(add, filename)
    if add != :prohibit && (add == :always || File.exist?(filename))
      case @type
      when :time
        s = create_time_addition(Time.now)
      when :number
        s = create_number_addition(@number)
        @number += 1
      else
        raise "Invalid type of addition."
      end
      if s.size == 0 || s.include?(' ') || s.include?('/')
        raise "Invalid additional part of filename: #{s.inspect}"
      elsif @last_addition == s
        raise "Create same addition: #{s.inspect}"
      end
      @last_addition = s
      return s
    end
    nil
  end
  private :get_addition

  def add_addition(filename, addition)
    case @position
    when :prefix
      dir, base = File.split(filename)
      dir + '/' + addition + @delimiter + base
    when :middle
      dir, base = File.split(filename)
      ext = File.extname(base)
      if ext.size > 0
        filename.sub(Regexp.new("\\#{ext}$"), @delimiter + addition + ext)
      else
        filename + @delimiter + addition
      end
    else # :suffix
      filename + @delimiter + addition
    end
  end
  private :add_addition

  def get_option_create(opts, key)
    opts.has_key?(key) ? opts[key] : @default_create[key]
  end
  private :get_option_create

  def create_directory(base, dir_opt)
    if dir_opt
      case dir_opt
      when :self
        dir = base
      when :parent
        dir = File.dirname(base)
      else
        raise ArgumentError, "Invalid directory option."
      end
      FileUtils.mkdir_p(dir)
    end
  end
  private :create_directory

  def touch_file(path)
    FileUtils.mkdir_p(File.dirname(path))
    open(path, 'w') {}
  end
  private :touch_file

  def write_file(path, file_opt)
    if file_opt
      case file_opt
      when :write
        unless File.exist?(path)
          touch_file(path)
        end
      when :overwrite
        touch_file(path)
      else
        raise ArgumentError, "Invalid file option."
      end
    end
  end
  private :write_file

  # The options are following:
  # [:extension (String of extension)]
  #  If we want to change extension, we set the value of the option.
  # 
  # [:add (:always, :auto, or :prohibit)]
  #  We specify if the additional part is used.
  #  * :always    - We always add.
  #  * :auto      - If the file exists, we add.
  #  * :prohibit  - Even if the file exists, we do not add.
  # 
  # [:directory (:self, :parent, or nil)]
  #  If the value is :self, we make directory of created filename.
  #  If the value is :parent, we make parent directory of created filename.
  #  If the value is nil, we do nothing.
  # 
  # [:file]
  #  If the value is :overwrite, we create a new empty file.
  #  If the value is :write and the file does not exist, we create an empty file.
  #  If the value is nil, we do nothing.
  def create(opts = {})
    base = get_basepath(get_option_create(opts, :extension))
    opt_add = get_option_create(opts, :add)
    if addition = get_addition(opt_add, base)
      path = add_addition(base, addition)
      while File.exist?(path)
        if addition = get_addition(opt_add, base)
          path = add_addition(base, addition)
        else
          raise "Can not create new filename."
        end
      end
      path
    else
      path = base
    end
    create_directory(path, get_option_create(opts, :directory))
    write_file(path, get_option_create(opts, :file))
    path
  end

  # If @format is a Proc object, we can not dump a FileName object.
  # But, even if @format is Proc object, the object created from configuration
  # can be dumped.
  def dump
    if not Proc === @format
      dumped = Marshal.dump(self)
    elsif @configuration_key
      tmp = @format
      @format = nil
      dumped = Marshal.dump(self)
      @format = tmp
    else
      raise "Can not dump."
    end
    dumped
  end

  def save_to(path)
    open(path, 'w') do |f|
      f.print dump
    end
  end

  def self.load(str)
    filename = Marshal.load(str)
    if key = filename.configuration_key
      opts = self.manage.configuration_setting(key)
      filename.format = opts[:format]
    end
    filename
  end

  def self.load_from(path)
    self.load(File.read(path))
  end

  # Executing FileName.new and FileName.create, we get new filename.
  # The same options of FileName.new are available.
  def self.create(basepath, *rest)
    self.new(basepath, *rest).create
  end

  @@manage = nil

  def self.manage
    @@manage = FileName::Manage.new unless @@manage
    @@manage
  end

  def self.configuration(*args)
    self.manage.configuration(*args)
  end

  class Manage
    @@filename_directory = File.join(ENV['HOME'], '.filename_gem')
    @@configuration = nil

    CONF_DIRECTORY = 'conf'
    CACHE_DIRECTORY = 'cache'
    SAMPLE_CONF_NAME = 'process.rb.example'

    def configuration_directory
      File.join(@@filename_directory, CONF_DIRECTORY)
    end

    def cache_directory(*file)
      File.join(@@filename_directory, CACHE_DIRECTORY, *file)
    end

    def load_configuration
      @@configuration = {}
      # old_safe_level = $SAFE
      # $SAFE = 2
      Dir.glob(configuration_directory + '/*.rb') do |path|
        if key = path.match(/\/([^\/]*)\.rb$/)[1]
          @@configuration[key.intern] = eval(File.read(path))
        end
      end
      # $SAFE = old_safe_level
    end

    def configuration_setting(key)
      load_configuration unless @@configuration
      @@configuration[key.intern]
    end

    def configuration(key, basepath, *rest)
      if opts = configuration_setting(key)
        if Hash === rest[-1]
          opts = opts.merge(rest.delete_at(-1))
        end
        filename = FileName.new(basepath, *rest, opts)
        filename.configuration_key = key
        return filename
      end
      return nil
    end

    def list_configuration
      Dir.glob(configuration_directory + "/*.rb").map { |s| File.basename(s).sub(/\.rb$/, '') }.sort
    end

    def save_cache(key, filename)
      dir = cache_directory
      FileUtils.mkdir_p(dir)
      filename.save_to(File.join(dir, key))
    end

    def load_cache(key)
      path = cache_directory(key)
      if File.exist?(path)
        return FileName.load_from(path)
      end
      return nil
    end

    def delete_cache(key)
      path = cache_directory(key)
      if File.exist?(path)
        FileUtils.rm(path)
      end
    end

    def list_cache
      Dir.glob(cache_directory + "/*").map { |s| File.basename(s) }.sort
    end

    def save_configuration_example
      dir = configuration_directory
      FileUtils.mkdir_p(dir)
      open(File.join(dir, SAMPLE_CONF_NAME), 'w') do |f|
        f.print <<SAMPLE
{
  :type => :number,
  :position => :middle,
  :path => :relative,
  :format => lambda { |n| sprintf("%05d_%02d", Process.pid, n) }
}
SAMPLE
      end
    end

  end

end
