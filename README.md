# Backtor

Backtor is an experimental, thread-based backport of Ractor to earlier Ruby
versions.

Since it's based on Ruby's `Thread` mechanism, you don't get the true
concurrency of Ractors, but it does mean that you can write applications using
Ractor and still have them work at a reduced speed in Ruby 2.

This is still a work in progress! The basic `yield`/`take` and `send`/`recv`
mechanisms are implemented, but very little else.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AaronC81/backtor.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
