# RiemannCheckHttp

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/riemann_check_http`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'riemann_check_http'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install riemann_check_http

## Usage

```ruby
require 'riemann_check_http'
$riemann_host = RIEMANN_SERVER
$riemann_port = '5555'
$domain = 'sample'
con = RiemannCheckHttp::Riemann.new host: $riemann_host, port: $riemann_port, domain: $domain
con.riemann_ttl = 500
con.http_open_timeout = 5
con.http_read_timeout = 30
con.use_ssl = true
con.use_pem = true
con.check_http 'sample.url.com', '501..598', '302..305', '301'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/riemann_check_http.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

