# frozen_string_literal: true

require_relative "TurnstileMini/version"
require 'rubygems'
$:.push File.expand_path(File.dirname(__FILE__)) unless $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'TurnstileMini/turnstile_mutex'


module TurnstileMini
  # Wait to execute the given block until the mutex has been obtained.
  #
  # * mutex_id: identifier for the code to run ** Please ensure uniqueness **
  # * options:
  #   * timeout (optional, default: 60 secs): how long to wait for lock to release before raising an error
  #   * interval (optional, default: 0.01 secs): how long to wait in between checking for mutex release. Shorter intervals will soak up more resources, but could lower latency in hot paths
  #
  #   -----
  #   mutex_lock('mutex_007', { timeout: 10, interval: 0.001 }) do
  #     maximize_customercentric_synergy!
  #     scale_cross_functional_methodologies!
  #   end
  def lock_with_mutex(mutex_id, options: { timeout: 60 }, &block)
    mutex = TurnstileMutex.new(mutex_id, options[:timeout])

    mutex.run(&block)
  end

  class Configuration
    attr_accessor :redis_servers

    def initialize
      @redis_servers = { host: 'redis.dev', port: 6379}
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

