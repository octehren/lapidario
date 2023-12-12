# Lapidario
'***Lapidario***' is a noun that is derived from the Latin '***lapidarius***', which means "***of or relating to engraved stones or inscriptions***." It can also mean "***one who engraves stones or inscriptions***".

It is also a Gemfile and Gemfile.lock static analyzer made to help with updating and managing of Gemfiles.

The idea for it was conceived while upgrading gem versions for a lot of Rails microservices at once.

Its main use is to make a Gemfile better reflect the current state of versions used in a project, and to specify or maintain explicit gem versions in order to better avoid [dependency hell](https://en.wikipedia.org/wiki/Dependency_hell).

## Installation

Install lts version:
```
gem install lapidario
```

Install pre-release version:
```
gem install lapidario --pre
```



## Usage

We'll start with example workflows as Lapidario's functionality and utility are clearer when presented in a context, and then go through explanations on what each option does.

### Example Workflow #1 : Performing a Minor Update

Little Johnny wants to update his Ruby project and hard-code all gems as static versions to make sure everyone working on it will have the exact same dependencies.

He has a pretty robust Gemfile with most versions organized so this is very unlikely to break any functionality.

First he runs `bundle update` and notices that some gems indeed switched versions in the Lockfile. He runs `bundle exec rspec` and verifies that no tests are breaking, so the Gemfile is good to be updated.

He will then run Lapidario to get versions from Gemfile.lock up to patch, have no version sign (meaning the version installed will be exact) and will just print the new Gemfile to the console:

```lapidario -l -d 3 -v 5```

After checking everything is OK, he'll run the same command with the addition of the `-w` (write) flag, which will also keep the original as backup:

```lapidario -l -d 3 -v 5 -w```

`-l` tells lapidario to get version information from the Gemfile, `-d` specifies the depth of the version precision, `-v 5` specifies that the version sign will be empty and `-w` specifies that the newly built Gemfile should overwrite the current Gemfile.

So if he had a line in his Gemfile that looked like this:
```ruby
gem 'rspec', '~> 3'
```
It will now look somewhat like this:
```ruby
gem 'rspec', '3.2.0'
```

He checks the new Gemfile and everything looks good. If that wasn't the case,lapidario conveniently created `Gemfile.original` for easy restoration.


### Example Workflow #2 : Deep Updating Many Gems
Some years go by and Little Johnny decided he must once again update his project.
He must update pretty much every gem, but decides to keep the RSpec version to better check if any new test failures are being caused by new gem features and changes in interfaces other than RSpec's own possible deprecations coming with a version bump.

So, in order to keep the gem line specifying RSpec, he adds a `# LOCK` comment to the right side of the line:
```ruby
gem 'rspec', '3.2.0' # LOCK
```

Now, he'll run `lapidario -r` to clear all version information from his gem lines, except for locked lines. So if he had lines that looked like this:
```ruby
gem 'pry', '0.14.0'
gem 'rspec', '3.2.0' # LOCK
```

They'll now look like this:
```ruby
gem 'pry'
gem 'rspec', '3.2.0' # LOCK
```

He will then run `bundle update` and, deciding to give the gems some room, will write the lockfile versions up to the minor version and using the tilde-greater-than sign to keep versions as updated as possible within their major versions. Both of these the default options (`depth = 2`, `sign = ~>`), so he'll just use the `-l` option:

```
lapidario -l
```

Now the output Gemfile will look something like this:

```ruby
gem 'pry', '~> 0.17'
gem 'rspec', '3.2.0' # LOCK
```

Looks great! He'll now save the Gemfile and skip the backup, to avoid saving a Gemfile.original :

```
lapidario -l -w -s
```

Such a tedious work avoided!


## Options
Lapidario is made to be extremely simple and easy to use. Here are all the available options:

### # LOCK
Not a command option, but add `# LOCK` to the right-side of the gem line you want ignored by Lapidario. Lines that do not specify gems, such as `ruby '3.2.2'`, `group :development do` and `end` are ignored by default.

### -h, --help
Shows the help message in the console.

### -w, --write                      
Writes output directly to Gemfile. Also backs up previous Gemfile to Gemfile.original, remember to remove it later.

### -s, --skip-backup                

Skips creation of backup Gemfile.original if writing to Gemfile. Does nothing if not used alongside the write option.

### -d, --depth NUMBER               
Selects depth (major = 1, minor = 2, patch = 3) of version string; min = 1, max = 3, default = 2;
Example: `3` has depth 1, `3.2` has depth 2 and `3.2.1` has depth 3.

### -v, --version-sign NUMBER        
Selects sign to use for version specification; this will be mapped from a number (0 = '~>', 1 = '>=', 2 = '<=', 3 = '>', 4 = '<', 5 = no sign). Default is `~>`. Note that it will write the same sign to all lines, so remember to lock the lines you don't want the sign applied to.

### -p, --path STRING                
Define path in which `Gemfile` and `Gemfile.lock` are located. Defaults to current directory.

### -g, --git-gems                   
Include GIT gems from Gemfile.lock in Gemfile reconstruction. This is off by default and will only affect the `--lock` command.
Note: This is not guaranteed to support branch or commit specification.
Gem lines are normalized to have the version and the remote under the `git:` key, like in this example:

#### Input (Gemfile.lock fragment)
```
GIT
  remote: https://github.com/jhawthorn/nsa.git
  revision: e020fcc3a54d993ab45b7194d89ab720296c111b
  ref: e020fcc3a54d993ab45b7194d89ab720296c111b
  specs:
    nsa (0.2.8)
```
#### Output
```ruby
gem 'nsa', '0.2.8', git: 'https://github.com/jhawthorn/nsa.git'
```

### -l, --lock                       
Rebuilds Gemfile using versions specified in Gemfile.lock; default sign for versions is '~>' and default depth is 2 (major & minor versions, ignores patch version).

##### Input Gemfile

```ruby
# ...
gem "rake"

group :development, :test do
  gem "pry", require: true

  gem "rspec"

  gem "rubocop"
end
```

##### Output Gemfile

```ruby
# ...

gem 'rake', '~> 13.1'

group :development, :test do
  gem 'pry', '~> 0.14', require: true

  gem 'rspec', '~> 3.12'

  gem 'rubocop', '~> 1.57'
end
```

### -r, --reset                      
Rebuilds Gemfile without gem versions, keeping other information present on the line.

###### Input Gemfile
```ruby
# ...
gem 'rake', '~> 13.1'

group :development, :test do
  gem 'pry', '~> 0.14', require: true

  gem 'rspec', '~> 3.12'

  gem 'rubocop', '~> 1.57'
end
```

##### Output Gemfile

```ruby
# ...
gem "rake"

group :development, :test do
  gem "pry", require: true

  gem "rspec"

  gem "rubocop"
end
```

**NOTE**: if a gem line has a ranged version only the first version will be excluded. 

For example:

```ruby
gem 'rails', '> 6', '<= 7.1'
```

Will become 

```ruby
gem 'rails', '<= 7.1'
```

### -f, --full-reset                 
Rebuilds Gemfile, removing all info but gem names (also applies to ranged versions).

###### Input Gemfile
```ruby
# ...
gem 'rake', '>= 13.1', '<= 14'

group :development, :test do
  gem 'pry', '~> 0.14', require: true

  gem 'rspec', '~> 3.12'

  gem 'rubocop', '~> 1.57'
end
```

##### Output Gemfile

```ruby
# ...
gem "rake"

group :development, :test do
  gem "pry"

  gem "rspec"

  gem "rubocop"
end
```

## TO DO:
- [x] Backup system: keep `Gemfile.original` stashed persistently
- [x] Add option to ignore Gemfile lines with `# LOCK` commented to the right end of the line
- [x] Normalize git gems with rubygems from Gemfile.lock
- [x] Add logic to ignore any comments in Gemfile gem lines
- [x] Normalize git gems with rubygems-sourced gems from Gemfile.lock

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bin/lapidario` to test changes in CLI integration.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/octehren/lapidario.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
