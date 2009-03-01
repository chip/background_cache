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
    end
    def self.caches
      @@caches
    end
  end
end