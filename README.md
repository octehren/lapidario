# Lapidario
'Lapidario' is a noun that is derived from the Latin 'lapidarius,' which means "of or relating to engraved stones or inscriptions." It can also mean "one who engraves stones or inscriptions".
It is also a Gemfile and Gemfile.lock static analyzer made to help with edition and management of Gemfiles.
The idea for it was conceived while upgrading gem versions for a lot of Rails microservices at once.
Its main use is to make a Gemfile better reflect the current state of versions used in a project, and also to specify or maintain explicit gem versions in order to better avoid [dependency hell](https://en.wikipedia.org/wiki/Dependency_hell).

## Installation

Install lts version:
`gem install lapidario`

Install pre-release version:
`gem install lapidario --pre`

## Example Workflow #1 : Updating Most Gems
Let's suppose you have a project that has not been updated in a while. You would like to update every gem version in your gemfile except for, say, RSpec.
<add # LOCK to the right of rspec, run lapidario reset, run bundle >

## Example Workflow #2 : Performing a Minor Update



## Usage

TODO: Write usage instructions here

### Gemfile 1

```ruby
# Gemfile 1 content here
source 'https://rubygems.org'

gem 'gem_name_1', 'version_1'
gem 'gem_name_2', 'version_2'
# Add more gems as needed
```

### Gemfile 2

```ruby
# Gemfile 2 content here
source 'https://rubygems.org'

gem 'gem_name_a', 'version_a'
gem 'gem_name_b', 'version_b'
# Add more gems as needed
```

## TO DO:
- [x] Backup system: keep `Gemfile.original` stashed persistently
- [x] Add option to ignore Gemfile lines with `# LOCK` commented to the right end of the line
- [x] Normalize git gems with rubygems from Gemfile.lock
- [x] Add logic to ignore any comments in Gemfile gem lines
- [ ] Normalize gems from other sources (such as GIT) with rubygems from Gemfile.lock

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bin/lapidario` to test changes in CLI integration.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/octehren/lapidario.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
