# Mutations Job

There is combination of two gems: mutations and sidekiq jobs

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add mutations_job 

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install mutations_job

## Usage

You can use `Mutations::Job` and then call `perform` method on it.

```ruby
class MyService < Mutations::Job
  required do
    string :name
  end
  optional do
    string :description
  end
  
  def execute
    puts "Run #{[name, description].compact.join(' ')}"
  end
end

MyService.perform_async(name: 'MyService', description: 'is running')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moskvin/mutations_job.
