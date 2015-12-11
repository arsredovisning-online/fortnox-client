Gem::Specification.new do |s|
  s.name        = 'fortnox-client'
  s.version     = '0.0.3'
  s.date        = '2015-12-03'
  s.summary     = "Fortnox client"
  s.description = "Fortnox client limited to account balances, description and verification idicator"
  s.authors     = ["Johan Grufman", "Jonas Lundström"]
  s.email       = 'info@mirendo.se'
  s.files       = ["lib/fortnox_client.rb"]
  s.add_dependency "net-http-persistent"
  s.add_development_dependency "rspec"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
end