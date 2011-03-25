# filename

The class to create filename that is not duplicated.
We select type of additional part of filename: number or time.

## Example

    basename = 'base.txt'
    filename = FileName.new(basename)
    p filename.create(:add => :always)    # => "/path/to/base.txt.00"
    p filename.create(:add => :always)    # => "/path/to/base.txt.01"
    p filename.create(:add => :always)    # => "/path/to/base.txt.02"

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

