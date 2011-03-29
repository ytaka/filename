autoload :FileUtils, 'fileutils'

# 
# The class to create filename that is not duplicated.
# We select type of additional part of filename: number or time.
# 
class FileName

  OPTIONS_CREATE = [:extension, :add, :directory]

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
  # [:extension]
  #  Default value of the option of FileName#create.
  # 
  # [:add]
  #  Default value of the option of FileName#create.
  #  
  # [:directory]
  #  Default value of the option of FileName#create.
  def initialize(basepath, opts = {})
    @basepath = File.expand_path(basepath)
    @number = opts[:start] || 0
    @digit = opts[:digit] || 2
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
      @format.call(t)
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
      @format.call(number)
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
  # [:directory (true or false)]
  #  If the value is true and the parent directory does not exist,
  #  we create the directory.
  def create(opts = {})
    base = get_basepath(get_option_create(opts, :extension))
    FileUtils.mkdir_p(File.dirname(base)) if get_option_create(opts, :directory)
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
      base
    end
  end

  # Executing FileName.new and FileName.create, we get new filename.
  # The same options of FileName.new are available.
  def self.create(basepath, opts = {})
    self.new(basepath, opts).create
  end

end
