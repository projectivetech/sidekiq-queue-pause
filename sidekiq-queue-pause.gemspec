Gem::Specification.new do |s|
  s.name          = 'sidekiq-queue-pause'
  s.version       = '0.0.4'
  s.summary       = 'Pause a Sidekiq queue'
  s.description   = 'Let\'s you pause/unpause individual sidekiq queues.'
  s.license       = 'MIT'
  s.authors       = ['FlavourSys Technology GmbH']
  s.email         = ['technology@flavoursys.com']
  s.homepage      = 'http://github.com/FlavourSys/sidekiq-queue-pause'

  s.require_paths = ['lib']
  s.files         = Dir['lib/**/*rb']

  s.add_dependency 'sidekiq', '>= 4.0'
end
