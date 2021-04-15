Gem::Specification.new do |s|
  s.name          = 'sidekiq-queue-pause'
  s.version       = '0.0.4'
  s.summary       = 'Pause a Sidekiq queue'
  s.description   = 'Let\'s you pause/unpause individual sidekiq queues.'
  s.license       = 'MIT'
  s.authors       = ['Projective Technology GmbH']
  s.email         = 'technology@projective.io'
  s.homepage      = 'https://github.com/projectivetech/sidekiq-queue-pause'

  s.require_paths = ['lib']
  s.files         = Dir['lib/**/*rb']

  s.add_dependency 'sidekiq', '>= 4.0', '< 5.0'
end
