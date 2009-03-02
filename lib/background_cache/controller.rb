module BackgroundCache
  module Controller
    def self.included(base)
      base.around_filter BackgroundCacheFilter.new
    end
  private
    class BackgroundCacheFilter
      def before(controller)
        # Triggered by adding ?background_cache to a path
        if controller.params.keys.include?("background_cache")
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