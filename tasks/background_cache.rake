desc "Background cache cron job"
task :background_cache => :environment do
  # Secure filters
  key = CACHE['background_cache/key'] = BackgroundCache::Config.key
  # Used to make requests
  session = ActionController::Integration::Session.new
  session.host = nil
  # Load the application background cache config (stay dynamic)
  session.get("/?background_cache_load=#{key}")
  # Retrieve caches from config
  load RAILS_ROOT + "/lib/background_cache_config.rb"
  caches = BackgroundCache::Config.caches
  caches.each do |cache|
    # Unique cache id for storing last expired time
    id = BackgroundCache::Config.unique_cache_id(cache)
    # Find out when this cache was last expired
    expired_at = CACHE[id]
    # If last expired doesn't exist or is older than :every
    if !expired_at || Time.now - expired_at > cache[:every]
      # Request action with ?background_cache
      session.get(session.url_for(cache[:params]) + "?background_cache=#{key}")
      # Update last expired time
      CACHE[id] = Time.now
    end
    puts id
  end
  # Unload the application background cache config
  session.get("/?background_cache_unload=#{key}")
end