# Sidekiq::QueuePause

This gem adds a `.pause` functionality to Sidekiq queues. Sidekiq Pro has this feature, so please consider upgrading if you can.

## Usage

Initializer:

```ruby
Sidekiq.configure_server do |config|
  Sidekiq.options[:fetch] = Sidekiq::QueuePause::PausingFetch

  # Optionally, you may set some unique key identifying the
  # Sidekiq process you want to control. This (server) process will
  # only be paused/unpaused when the function gets called with
  # the corresponding key. See below.
  Sidekiq::QueuePause.process_key = 'foo'

  # You may also pass in a Proc which is then evaluated when needed.
  Sidekiq::QueuePause.process_key { SomeClass.some_method }

  # Optionally, you may configure the sleep period (in seconds) after the
  # queue lock has been checked. By default, the fetcher will sleep for
  # Sidekiq::Fetcher::TIMEOUT, i.e. the same time that the redis fetch
  # command may take.
  Sidekiq::QueuePause.retry_after = 5
end
```

Pausing a queue:

```ruby
Sidekiq::QueuePause.pause(:example)
```

```ruby
# With process key:
Sidekiq::QueuePause.pause(:example, 'foo')
```

```ruby
# On a queue object:
example = Sidekiq::Queue.new(:example)
example.pause
```

```ruby
# On a queue object with process key:
example.pause('foo')
```

Unpause:

```ruby
Sidekiq::QueuePause.unpause(:example)
```

etc.

Getting pause status:

```ruby
Sidekiq::QueuePause.paused?(:example)
# => true/false
```

etc.

Unpause all queues/processes:

```ruby
Sidekiq::QueuePause.unpause_all
```

## License

The gem is licensed under the [MIT-License](COPYING).
