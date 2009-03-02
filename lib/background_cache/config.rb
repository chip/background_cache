module BackgroundCache
  class Config
    @@caches = []
    def initialize(&block)
      yield self
    end
    def cache(options)
      # Convert keys to strings for param matching
      options.dup.each do |key, value|
        options[key.to_s] = value
        options.delete(key)
      end
      @@caches.push({
        :every => @every,
        :fragment => options.delete('fragment'),
        :layout => options.delete('layout'),
        :url_for => options
      })
    end
    def every(seconds, &block)
      @every = seconds
      yield
    end
    # Unique cache id for storing last expired time
    def self.cache_id(cache)
      id = []
      join = lambda do |k, v|
        if k && v
          [ k, v ].collect { |kv| kv.to_s.gsub(/\W/, '_') }.join('-')
        else nil
        end
      end
      cache[:url_for].each do |key, value|
        id << join.call(key, value)
      end
      cache.each do |key, value|
        next if key == :url_for
        id << join.call(key, value)
      end
      'background_cache/' + id.compact.join('/')
    end
    def self.caches
      @@caches
    end
  end
end