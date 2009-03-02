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
        # Reload the background cache config (stay dynamic)
        if controller.params[:background_cache_config] == key
          load RAILS_ROOT + "/lib/background_cache_config.rb"
        # Reload the cache for an entire page, action, or fragment
        elsif controller.params[:background_cache] == key
          controller.params.delete("background_cache")
          # Retrieve caches from config
          caches = BackgroundCache::Config.caches
          # Find cache that matches params
          @cache = caches.select { |item| item[:url_for] == controller.params }[0]
          if @cache
            # Store current layout, then disable it
            if @cache[:layout] == false
              @layout = controller.active_layout
              controller.class.layout(false)
            end
            # Expire fragment
            if @cache[:fragment]
              controller.expire_fragment(@cache[:fragment])
            # Expire everything
            else
              ActsAsCached.config[:skip_gets] = true
            end
          end
        end
      end
      def after(controller)
        if @cache
          # Restore layout
          if @cache[:layout] == false
            controller.class.layout(@layout)
          end
          # Stop expiring
          ActsAsCached.config[:skip_gets] = false
          @cache = nil
        end
      end
    end
  end
end