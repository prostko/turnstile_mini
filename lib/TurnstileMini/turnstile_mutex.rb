require 'logging'
require 'redis'

module TurnstileMini
  class TurnstileMutexTimeoutError < Exception; end

  class TurnstileMutex
    class << self
      def cache
        @cache ||= Redis.new(TurnstileMini.configuration.redis_servers)
      end
    end

    def initialize(key, timeout = 60, interval = 0.1)
      @key = key
      @timeout = timeout
      @interval = interval
    end

    def run
      @start_time = Time.now
      yield
    ensure
      unlock!
    end

    def current_lock
      cache.get(@key)
    end

    private

    def timeout?
      Time.now > @start_time + @timeout
    end

    def lock!
      until timeout?
        return if attempt_to_lock == my_lock_id
        sleep(@interval)
      end
      raise TimeoutError.new("Failed to obtain a lock within #{@timeout} seconds.")
    end

    def attempt_to_lock
      if current_lock.nil?
        set_current_lock
      end
      current_lock
    end

    def unlock!
      cache.del(@key) if locked_by_me?
    end

    def locked_by_me?
      current_lock == process_id
    end

    def set_current_lock
      cache.set(@key, process_id)
      # expire redis key after 1 hour
      cache.expire(@key, 3600)
    end

    def process_id
      @process_id ||= "#{Process.pid.to_s}#{Thread.current.object_id}#{Thread.current.to_s}"
    end

    def cache
      self.class.cache
    end
  end
end