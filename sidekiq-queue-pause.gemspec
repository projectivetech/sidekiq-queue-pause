Gem::Specification.new do |s|
  s.name = "sidekiq-queue-pause"
  s.version = "0.1.1"
  s.summary = "Pause a Sidekiq queue"
  s.description = "Let's you pause/unpause individual sidekiq queues."
  s.license = "MIT"
  s.authors = ["Projective Technology GmbH"]
  s.email = "technology@projective.io"
  s.homepage = "https://github.com/projectivetech/sidekiq-queue-pause"

  s.require_paths = ["lib"]
  s.files = Dir["lib/**/*rb"]

  s.add_dependency "sidekiq", ">= 6.0", "< 8.0"

  s.add_development_dependency "rspec", "~> 3"
  s.add_development_dependency "simplecov", "~> 0.21"
  s.add_development_dependency "solargraph", "~> 0.44"
  s.add_development_dependency "solargraph-standardrb", "~> 0.0.4"
  s.add_development_dependency "standard", "~> 1.4"
  s.add_development_dependency "guard", "~> 2.18"
  s.add_development_dependency "guard-rspec", "~> 4.7"
  s.add_development_dependency "pronto", "~> 0.11"
  s.add_development_dependency "pronto-standardrb", "~> 0.1"
  s.add_development_dependency "pronto-simplecov", "~> 0.11"
end
