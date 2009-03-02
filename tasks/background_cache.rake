desc "Background cache cron job"
task :background_cache => :environment do
  # Secure filters
  key = CACHE['background_cache/key'] = BackgroundCache::Config.key
  # Used to make requests
  session = ActionController::Integration::Session.new
  session.host = nil
  # Reload the application background cache config (stay dynamic)
  session.get("/?background_cache_config=#{key}")
  # Retrieve caches from config
  load RAILS_ROOT + "/lib/background_cache_config.rb"
  caches = BackgroundCache::Config.caches
  caches.each do |cache|
    # Unique cache id for storing last expired time
    id = BackgroundCache::Config.unique_cache_id(cache)
    # Find out when this cache was last expired
    expired_at = CACHE[id]
    expired_at = Marshal::load(expired_at) if expired_at
    # If last expired doesn't exist or is older than :every
    if !expired_at || Time.now - expired_at > cache[:every]
      # Request action with ?background_cache
      session.get(session.url_for(cache[:url_for]) + "?background_cache=#{key}")
      # Update last expired time
      CACHE[id] = Marshal.dump(Time.now)
    end
    puts id
  end
end