desc "Background cache cron job"
task :background_cache => :environment do
  # Retrieve caches from config
  caches = BackgroundCache::Config.caches
  caches.each do |cache|
    # Unique cache id for storing last expired time
    id = BackgroundCache::Config.cache_id(cache)
    # Find out when this cache was last expired
    expired_at = CACHE[id]
    expired_at = Marshal::load(expired_at) if expired_at
    # If last expired doesn't exist or is older than :every
    if !expired_at || Time.now - expired_at > cache[:every]
      # Execute request to action with ?background_cache
      session = ActionController::Integration::Session.new
      session.host = nil
      session.get(session.url_for(cache[:url_for]) + '?background_cache')
      # Update last expired time
      CACHE[id] = Marshal.dump(Time.now)
    end
    puts id
  end
end