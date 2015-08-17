require "vcr"
require "pathname"

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

def require_from_root(file)
  require_relative "../#{file}"
end
