# filename

This gem includs the class FileName to create filename that is not duplicated
and command 'filename-create' for shell.
We select type of additional part of filename: number or time.

## Installation

    gem install filename

## How to use as library

We need to require 'filename'.

    require 'filename'

And then we create method for an instance of FileName or
class method FileName.create.

### Filenames with sequential numbers

Default options add suffixes and use additional parts of sequential numbers.

    require 'filename'
    filename = FileName.new('base.txt')
    # Same as FileName.new('base.txt', :type => :number, :digit => 2, :position => :suffix, :start => 0, :delimiter => '.')
    p filename.create(:add => :always)    # => "/path/to/base.txt.00"
    p filename.create(:add => :always)    # => "/path/to/base.txt.01"
    p filename.create(:add => :always)    # => "/path/to/base.txt.02"

### Filenames with time strings

    require 'filename'
    filename = FileName.new('base.txt', :type => :time)
    p filename.create(:add => :always)    # For example, returns "/path/to/base.txt.20110326_073247_078247"

### Control adding additional parts

    require 'filename'
    filename = FileName.new('base.txt')
    p filename.create(:add => :always)    # Always returns "/path/to/base.txt.00"
    p filename.create(:add => :prohibit)  # Always returns "/path/to/base.txt"
    p filename.create(:add => :auto)      # If the file exist, returns "/path/to/base.txt.00". Otherwise, "/path/to/base.txt"

### Add additinal parts to prefix or middle position

    require 'filename'
    filename = FileName.new('base.txt', :position => :prefix)
    p filename.create(:add => :always)    # => "/path/to/00_base.txt"
    
    filename = FileName.new('base.txt', :position => :middle)
    p filename.create(:add => :always)    # => "/path/to/base_00.txt"

### Change delimiters

    require 'filename'
    filename = FileName.new('base.txt', :position => :prefix, :delimiter => '')
    p filename.create(:add => :always)    # => "/path/to/00base.txt"
    
    filename = FileName.new('base.txt', :position => :prefix, :delimiter => '-')
    p filename.create(:add => :always)    # => "/path/to/00-base.txt"

### Change extensions

    require 'filename'
    filename = FileName.new('base.txt')
    p filename.create(:add => :always, :extension => 'log')    # => "/path/to/base.log.00"

### Create parent directory

    require 'filename'
    filename = FileName.new('dir/base.txt')
    p filename.create(:add => :always, :directory => :parent)    # Create 'dir' directory.

### Create directory of created filename

    require 'filename'
    filename = FileName.new('dir1/dir2')
    p filename.create(:add => :always, :directory => :self)    # Create 'dir1/dir2' directory.

### Change starting numbers and digits of sequential numbers

    require 'filename'
    filename = FileName.new('base.txt', :digit => 4, :start => 1000)
    p filename.create(:add => :always)    # => "/path/to/base.txt.1000"
    p filename.create(:add => :always)    # => "/path/to/base.txt.1001"

### Change formats of sequential numbers

    require 'filename'
    filename = FileName.new('base.txt', :format => "@%03d@")
    p filename.create(:add => :always)    # => "/path/to/base.txt.@000@"
    
    filename = FileName.new('base.txt', :type => :number, :format => lambda { |n| sprintf("%03d", n * n) })
    p filename.create(:add => :always)    # => "/path/to/base.txt.100"
    p filename.create(:add => :always)    # => "/path/to/base.txt.121"

### Change formats of time strings

    require 'filename'
    filename = FileName.new('base.txt', :format => "%H%M%S")
    p filename.create(:add => :always)    # For example, returns "/path/to/base.txt.075130"
    
    filename = FileName.new('base.txt', :start => 10, :format => lambda { |t| t.usec.to_s })
    p filename.create(:add => :always)    # For example, returns "/path/to/base.txt.849963"

### Use of variable for proc set by :format option

    require 'filename'
    filename = FileName.new('base.txt', :data => { :a => 3 },
                            :format => lambda { |n| s = sprintf("%03d", @a * n); @a += 2; s })
    p filename.create(:add => :always)    # => "/path/to/base.txt.000"
    p filename.create(:add => :always)    # => "/path/to/base.txt.005"
    p filename.create(:add => :always)    # => "/path/to/base.txt.014"

## How to use command 'filename-create'

filename-create with 'new' and basename puts path of file.

    filename-create new basename

We can use the corresponding options to optional arguments of
FileName#create.

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
    -c, --cache KEY                  Create cache for command "new" and "config".

To create sequential filenames, we call 'filename-create new' with '--cache' option
and then 'filename-create cache'.

    filename-create new basename --add always --cache base
    filename-create cache base
      /path/to/basename.00
    filename-create cache base
      /pat/to/basename.01

## Contributing to filename
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Takayuki YAMAGUCHI. See LICENSE.txt for
further details.
