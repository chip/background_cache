require 'digest/sha2'

module BackgroundCache
  class Config
    def initialize(&block)
      @@caches = []
      yield self
    end
    def cache(options)
      # Convert keys to strings for param matching
      options.dup.each do |key, value|
        options[key.to_s] = value
        options.delete(key)
      end
      # Method-style config
      options = @options.merge(options)
      # Store the cache options
      @@caches.push({
        :every => options.delete('every') || 1.hour,
        :fragment => options.delete('fragment'),
        :layout => options.delete('layout'),
        :url_for => options
      })
    end
    def every(value, &block)
      set_option(:every, value, &block)
    end
    def fragment(value, &block)
      set_option(:fragment, value, &block)
    end
    def layout(value, &block)
      set_option(:layout, value, &block)
    end
    def set_option(key, value, &block)
      @options ||= {}
      @options[key.to_s] = value
      if block
        yield
        @options = {}
      end
      self
    end
    def self.caches
      @@caches
    end
    def self.key
      Digest::SHA256.hexdigest("--#{Time.now}--#{rand}--")
    end
    # Unique cache id for storing last expired time
    def self.unique_cache_id(cache)
      id = []
      join = lambda do |k, v|
        id << (k.nil? || v.nil? ?
          nil : [ k, v ].collect { |kv| kv.to_s.gsub(/\W/, '_') }.join('-')
        )
      end
      cache[:url_for].each do |key, value|
        join.call(key, value)
      end
      cache.each do |key, value|
        join.call(key, value) unless key == :url_for
      end
      'background_cache/' + id.compact.join('/')
    end
  end
end