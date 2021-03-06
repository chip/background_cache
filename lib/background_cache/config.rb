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
        :except => options.delete('except'),
        :every => options.delete('every') || 1.hour,
        :layout => options.delete('layout'),
        :only => options.delete('only'),
        :params => options
      })
    end
    def except(value, &block)
      set_option(:except, value, &block)
    end
    def every(value, &block)
      set_option(:every, value, &block)
    end
    def layout(value, &block)
      set_option(:layout, value, &block)
    end
    def only(value, &block)
      set_option(:only, value, &block)
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
    # Find cache config from params
    def self.from_params(params)
      from_params_and_fragment(params)
    end
    def self.from_params_and_fragment(params, fragment=nil)
      unless @@caches.empty?
        @@caches.select { |item|
          # Basic params match (action, controller, etc)
          item[:params] == params &&
          (
            # No fragment specified
            fragment.nil? ||
            (
              (
                # :only not defined
                !item[:only] ||
                # :only matches fragment
                item[:only] == fragment ||
                (
                  # :only is an array
                  items[:only].respond_to?(:index) &&
                  # :only includes matching fragment
                  items[:only].include?(fragment)
                )
              ) &&
              (
                # :except not defined
                !item[:except] ||
                # :except not explicitly named
                item[:except] != fragment ||
                (
                  # :except is an array
                  items[:except].respond_to?(:index) &&
                  # :except does not include matching fragment
                  !items[:except].include?(fragment)
                )
              )
            )
          )
        }[0]
      end
    end
    def self.caches
      @@caches
    end
    def self.key
      Digest::SHA256.hexdigest("--#{Time.now}--#{rand}--")
    end
    def self.load!
      load RAILS_ROOT + "/lib/background_cache_config.rb"
    end
    def self.unload!
      @@caches = []
    end
    # Unique cache id for storing last expired time
    def self.unique_cache_id(cache)
      id = []
      join = lambda do |k, v|
        id << (k.nil? || v.nil? ?
          nil : [ k, v ].collect { |kv| kv.to_s.gsub(/\W/, '_') }.join('-')
        )
      end
      cache[:params].each do |key, value|
        join.call(key, value)
      end
      cache.each do |key, value|
        join.call(key, value) unless key == :params
      end
      'background_cache/' + id.compact.join('/')
    end
  end
end