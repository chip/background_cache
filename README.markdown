BackgroundCache
===============

Use a rake task to expire any number of fragments or actions, with or without layout. Uses Rails and cache_fu.

Dynamic Configuration
---------------------

Create *lib/background\_cache\_config.rb*:

<pre>
BackgroundCache::Config.new do |config|

  # Configure a background cache in one call
  Tag::League.find(:all).each do |tag|
    config.cache(
      # Route params
      :controller => 'sections',
      :action => 'teams',
      :tag => tag.permalink,
      # Background cache options
      :every => 1.hour,
      :fragment => "sections_teams_#{tag.permalink}",
      :layout => false
    )
  end
  
  # Group configure using block methods
  config.every(1.hour).fragment("sections_teams_#{tag.permalink}").layout(false) do
    Tag::League.find(:all).each do |tag|
      config.cache(
        :controller => 'sections',
        :action => 'teams',
        :tag => tag.permalink
      )
    end
  end
  
  # Or use a mix of the two
end
</pre>

If no fragment is specified, all of the action's caches will regenerate.

This configuration reloads every time the rake task runs. New records get background cached.

Rake task
---------

Add <code>rake background_cache</code> to cron. Set the job's duration the same as your shortest cache.

What does the rake task do?

* Adds a security key to memcache that is shared by the app and rake task
* Sends a request to the app to reload its BackgroundCache config
* If time for a cache to expire, the task sends an expire request to the action
* BackgroundCache detects the request within the app and modifies the layout or expiry as configured

Memcached is employed to track the expire time of each background cache. As a side benefit, if memcached restarts, the rake task knows to generate all caches.

Todo
----

* Specs