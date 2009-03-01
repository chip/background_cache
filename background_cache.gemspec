Gem::Specification.new do |s|
  s.name    = 'background_cache'
  s.version = '0.1'
  s.date    = '2008-02-28'
  
  s.summary     = "Generate caches before your users do"
  s.description = "Generate caches before your users do"
  
  s.author   = 'Winton Welsh'
  s.email    = 'mail@wintoni.us'
  s.homepage = 'http://github.com/winton/background_cache'
  
  s.has_rdoc = false
  
  # = MANIFEST =
  s.files = %w[
    MIT-LICENSE
    README.markdown
    Rakefile
    background_cache.gemspec
    changelog.markdown
    init.rb
    lib/background_cache.rb
    lib/background_cache/config.rb
    lib/background_cache/controller.rb
    spec/spec.opts
    spec/spec_helper.rb
  ]
  # = MANIFEST =
end