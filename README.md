# filename

The gem 'filename' is used to create filenames that have sequential numbers,
time strings, or strings of other formats not to be duplicated.
This includes the class FileName and command 'filename-create' for shell.

* [http://rubygems.org/gems/filename](http://rubygems.org/gems/filename)
* [http://rubydoc.info/gems/filename/](http://rubydoc.info/gems/filename/)

## Installation

We can install gem command.

    gem install filename

## Requirements

filename is tested on ruby 1.9.2.
For arguments with variable length errors occur on ruby 1.8.7.

## How to use as library

We need to require 'filename'.

    require 'filename'

And then we call 'create' method for an instance of FileName or
class method 'FileName.create'.

### Filenames with sequential numbers

Default options add suffixes and use additional parts of sequential numbers.

    require 'filename'
    filename = FileName.new('base.txt')
    # Same as FileName.new('base.txt', :type => :number, :digit => 2, :position => :suffix, :start => 0, :delimiter => '.')
    p filename.create(:add => :always)    # => "/path/to/base.txt.00"
    p filename.create(:add => :always)    # => "/path/to/base.txt.01"
    p filename.create(:add => :always)    # => "/path/to/base.txt.02"

We give a base filename and get an instance of FileName.
Then, we get filenames with sequential numbers
by FileName#create.
The default value of option :add of FileName#create is :auto
and add some string to filename if the targeted file exists.
If we set :auto to the option :add as the above example,
we add always add some string to filename.

### Filenames with time strings

    require 'filename'
    filename = FileName.new('base.txt', :type => :time)
    p filename.create(:add => :always)    # For example, returns "/path/to/base.txt.20110326_073247_078247"

If we set :time to the option :type of FileName.new,
we add time string to filename.
The default value of the option :type is :number and
we add a number to filename.

### Control adding additional parts

    require 'filename'
    filename = FileName.new('base.txt')
    p filename.create(:add => :always)    # Always returns "/path/to/base.txt.00"
    p filename.create(:add => :prohibit)  # Always returns "/path/to/base.txt"
    p filename.create(:add => :auto)      # If the file exist, returns "/path/to/base.txt.00". Otherwise, "/path/to/base.txt"

### Add additional parts to prefix or middle position

An option :position controls positions of additional strings.
The value :suffix, :prefix, and :middle are accepted.
The default is :suffix.

    require 'filename'
    filename = FileName.new('base.txt', :position => :prefix)
    p filename.create(:add => :always)    # => "/path/to/00_base.txt"
    
    filename = FileName.new('base.txt', :position => :middle)
    p filename.create(:add => :always)    # => "/path/to/base_00.txt"

### Change delimiters

The default delimiter is "." if the option :position is :suffix.
Otherwise, the string is "_".
If we want to change delimiter string, we set desired string to
an option :delimiter.

    require 'filename'
    filename = FileName.new('base.txt', :position => :prefix, :delimiter => '')
    p filename.create(:add => :always)    # => "/path/to/00base.txt"
    
    filename = FileName.new('base.txt', :position => :prefix, :delimiter => '-')
    p filename.create(:add => :always)    # => "/path/to/00-base.txt"

### Change extensions

If we want to change extension of base filename,
we set an option :extension.

    require 'filename'
    filename = FileName.new('base.txt')
    p filename.create(:add => :always, :extension => 'log')    # => "/path/to/base.log.00"

### Create parent directory

If we set :parent to an option :directory,
we make the parent directories on creating filenames.

    require 'filename'
    filename = FileName.new('dir/base.txt')
    p filename.create(:add => :always, :directory => :parent)    # Create 'dir' directory.

### Create directory of created filename

If we set :self to an option :directory,
we make the directories of created filenames.

    require 'filename'
    filename = FileName.new('dir1/dir2')
    p filename.create(:add => :always, :directory => :self)    # Create 'dir1/dir2' directory.

### Create empty file

If we set an option :file, we can create an empty file.
If the value is :write and the targeted file does not exist,
we create an empty file.
If the value is :overwrite, we always create an empty file.

    require 'filename'
    filename = FileName.new('path/to/file')
    p filename.create(:file => :write)        # Create empty file 'path/to/file' if 'path/to/file' does not exist.
    p filename.create(:file => :overwrite)    # Create empty file 'path/to/file' even if 'path/to/file' exists.

### Change starting numbers and digits of sequential numbers

We can set starting number by an option :start and
digit number by an option :digit.

    require 'filename'
    filename = FileName.new('base.txt', :digit => 4, :start => 1000)
    p filename.create(:add => :always)    # => "/path/to/base.txt.1000"
    p filename.create(:add => :always)    # => "/path/to/base.txt.1001"

### Change formats of sequential numbers

If we set string object to an option :format,
the value is used by method sprintf.
If we set proc object that take Fixnum,
we use the evaluation of the proc object as an additional string.

    require 'filename'
    filename = FileName.new('base.txt', :format => "@%03d@")
    p filename.create(:add => :always)    # => "/path/to/base.txt.@000@"
    
    filename = FileName.new('base.txt', :type => :number, :format => lambda { |n| sprintf("%03d", n * n) })
    p filename.create(:add => :always)    # => "/path/to/base.txt.100"
    p filename.create(:add => :always)    # => "/path/to/base.txt.121"

### Change formats of time strings

We can set a string or proc object to an option :format
similar to the case of number type.
If the value is a string, we use the string as first argument of
method sprintf.
If the value is a proc object, we evaluate it and
use returned value as an additional part.

    require 'filename'
    filename = FileName.new('base.txt', :format => "%H%M%S")
    p filename.create(:add => :always)    # For example, returns "/path/to/base.txt.075130"
    
    filename = FileName.new('base.txt', :start => 10, :format => lambda { |t| t.usec.to_s })
    p filename.create(:add => :always)    # For example, returns "/path/to/base.txt.849963"

### Use of variable for proc set by :format option

If we give a hash to an option :data,
the values of the hash are saved as instance variables.
We can use the variables in proc object for an option :format.

    require 'filename'
    filename = FileName.new('base.txt', :data => { :a => 3 },
                            :format => lambda { |n| s = sprintf("%03d", @a * n); @a += 2; s })
    p filename.create(:add => :always)    # => "/path/to/base.txt.000"
    p filename.create(:add => :always)    # => "/path/to/base.txt.005"
    p filename.create(:add => :always)    # => "/path/to/base.txt.014"

In the above example we prepare the instance variable "@a = 3"
and use @a in proc object specified by an option :format.

### Options of FileName#new, FileName#create, and FileName.create

If we set options of FileName#create to FileName#new,
the values is the default values of FileName#create.
If we want to change on creating filenames, 
we set options for FileName#create.
Options of FileName.create are the same as these of FileName#new.

## How to use command 'filename-create'

We can use command 'filename-create' on shell.

### Basic usage and options

filename-create with 'new' and basename puts path of file.

    filename-create new basename

Then the created filename is displayed.

We can use the options corresponding to
the optional arguments of FileName#create
except for "--cache" option.
We also can not set proc object to :format by command filename-create.

    -s, --start NUM                  Set the starting number.
    -i, --digit NUM                  Set the digit of number.
    -d, --delimiter STR              Set the delimiter string: number or time.
    -n, --no-delimiter               Do not use delimiter.
    -t, --type TYPE                  Set the type of additional part.
    -f, --format STR                 Set the format string.
    -p, --position POS               Set the position of addition: prefix, suffix, or middle.
    -P, --path TYPE                  Set the type of path: absolute or relative.
    -e, --extension STR              Set the extension string.
    -a, --add STR                    Change the behavior of addition: always, auto, or prohibit.
    -D, --directory STR              Create directory: self or parent.
    -F, --file STR                   Create an empty file: write or overwrite.
    -c, --cache KEY                  Create cache for command "new" and "config".

### cache

To create sequential filenames, we call 'filename-create new' with '--cache' option
to create cache. At this point, we set options that we want to use.

    filename-create new basename --add always --cache cache_name

We refer created cache by 'cache_name'.
To generate filenames from cache we type the following.

    filename-create cache cache_name

Sequential commands create filenames with sequential numbers.

When we finish to use the cache,
we type

    filename-create delete_cache cache_name

and then delete the cache.

To list the saved cache, we type

    filename-create list_cache

### Configuration files

If we save files in directory ~/.filename\_gem/conf,
which define a ruby hash of options of FileName#create,
we can use the configurations to create filenames.
If there is ~/.filename\_gem/conf/sample.rb that preserves an option hash,
we type

    filename-create config sample

and get filename from the configuration.
We can also create cache to type it with "--cache" option
same as "filename-create new".

## Contributing to filename
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## License

The license is GPLv3.
See LICENSE.txt for further details.

## Copyright

Copyright (c) 2011 Takayuki YAMAGUCHI. 
