Gem::Specification.new do |s|
  s.name        = 'fortnox-client'
  s.version     = '0.0.1'
  s.date        = '2015-06-26'
  s.summary     = "Fortnox client"
  s.description = "Fortnox client limited to accounting balances"
  s.authors     = ["Johan Grufman"]
  s.email       = 'info@mirendo.se'
  s.files       = ["lib/fortnox_client.rb"]
  s.add_dependency "net-http-persistent"
  s.add_development_dependency "rspec"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
end