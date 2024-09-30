module TurnstileMutex

  def self.get_current_lock(mutex_id)
    DistributedMutex.new(mutex_id).current_lock
  end

  ##
  # Wraps code that should only be run when the mutex has been obtained.
  #
  # The mutex_id uniquely identifies the section of code being run.
  #
  # You can optionally specify a :timeout to control how long to wait for the lock to be released
  # before raising a MegaMutex::TimeoutError
  #
  #   with_distributed_mutex('my_mutex_id_1234', :timeout => 20) do
  #     do_something!
  #   end
  def mutex_locking(mutex_id, options = {}, &block)
    mutex = DistributedMutex.new(mutex_id, options[:timeout])
    mutex.run(&block)
  end

  class Configuration
    attr_accessor :redis_servers, :namespace

    def initialize
      @redis_servers = {:host => 'redis.dev', :port => 6379}
      @namespace = 'mega_mutex'
    end
  end

  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end