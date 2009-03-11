module BackgroundCache
  module Helper
    def cache_with_background_cache(name = {}, options = nil, &block)
      cache = BackgroundCache::Config.from_params_and_fragment(params, name)
      if cache
        # http://api.rubyonrails.org/classes/ActionView/Helpers/CacheHelper.html
        # http://api.rubyonrails.org/classes/ActionController/Caching/Fragments.html
        # ActionController::Caching::Fragments#fragment_for (undocumented)
        pos = output_buffer.length
        block.call
        @controller.write_fragment(name, buffer[pos..-1], options)
      else
        cache_without_background_cache(name, options, &block)
      end
    end
    alias_method_chain :cache, :background_cache
  end
end