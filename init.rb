$:.unshift File.dirname(__FILE__) + "/lib"
require 'background_cache'

ActionController::Base.send(:include, BackgroundCache::Controller)