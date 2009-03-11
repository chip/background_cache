module BackgroundCache
  module Controller
    def self.included(base)
      base.around_filter BackgroundCacheFilter.new
    end
      
    private
    class BackgroundCacheFilter
      def before(controller)
        # Secure filters
        key = CACHE['background_cache/key']
        # Load the background cache config (stay dynamic)
        if controller.params[:background_cache_load] == key
          BackgroundCache::Config.load!
        # Unload the background cache config
        elsif controller.params[:background_cache_unload] == key
          BackgroundCache::Config.unload!
        # Reload the cache for an entire page, action, or fragment
        elsif controller.params[:background_cache] == key
          @cache = BackgroundCache::Config.from_params(params)
          # Store current layout, then disable it
          if @cache && @cache[:layout] == false
            @layout = controller.active_layout
            controller.class.layout(false)
          end
        end
        controller.params.delete("background_cache")
        controller.params.delete("background_cache_load")
        controller.params.delete("background_cache_unload")
        true
      end
      def after(controller)
        if @cache
          # Restore layout
          if @cache[:layout] == false
            controller.class.layout(@layout)
          end
        end
      end
    end
  end
end