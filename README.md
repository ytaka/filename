# filename

The class to create filename that is not duplicated.
We select type of additional part of filename: number or time.

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
    p filename.create(:add => :always, :directory => true)    # Create 'dir' directory.

### Change starting numbers and digits of sequential numbers

    require 'filename'
    filename = FileName.new('base.txt', :digit => 4, :start => 1000)
    p filename.create(:add => :always)    # => "/path/to/base.txt.1000"
    p filename.create(:add => :always)    # => "/path/to/base.txt.1001"

### Change formats of sequential numbers

    require 'filename'
    filename = FileName.new('base.txt', :format => "@%03d@")
    p filename.create(:add => :always)    # => "/path/to/base.txt.@000@"
    
    filename = FileName.new('base.txt', :type => :time, :format => lambda { |n| sprintf("%03d", n * n) })
    p filename.create(:add => :always)    # => "/path/to/base.txt.100"
    p filename.create(:add => :always)    # => "/path/to/base.txt.121"

### Change formats of time strings

    require 'filename'
    filename = FileName.new('base.txt', :format => "%H%M%S")
    p filename.create(:add => :always)    # For example, returns "/path/to/base.txt.075130"
    
    filename = FileName.new('base.txt', :start => 10, :format => lambda { |t| t.usec.to_s })
    p filename.create(:add => :always)    # For example, returns "/path/to/base.txt.849963"

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
