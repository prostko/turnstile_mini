# TurnstileMini

 Simple Redis-backed mutex
 - Uses the given mutex_id to store a unique process id, that key.value is our mutex
 - Redis-backed means the mutex works wherever your distributed redis cache does

* Does not guarantee order *

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add TurnstileMini

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install TurnstileMini

## Usage

     class SavingsAccountSweeper
       include TurnstileMini

       def process_account_sweep
         lock_with_mutex("SavingsAccountSweeper::nightly_account_sweep") do
           process_sweep if should_sweep_account?
         end
       end
     end

     # options = {
         timeout: 60,    # seconds to wait for lock before raising, default 60
         interval: 0.001 # seconds interval to wait before checking for lock release, default 0.01
     # }
     # Use lock_with_mutex(:mutexid, options )

## Configuration 

*** Requires Redis ***
By default, connects to the local redis server, but you can configure production, etc:

     REDIS_HOST = 'loremipsum'
     REDIS_PORT = '5232'

     TurnstileMini.configure do |config|
       config.redis_servers = { host: REDIS_HOST, port: REDIS_PORT}
     end

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TurnstileMini project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/TurnstileMini/blob/master/CODE_OF_CONDUCT.md).
