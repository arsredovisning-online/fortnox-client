require 'fast_spec_helper'
require_from_root 'lib/fortnox/fortnox_url'

describe FortnoxUrl do

  specify { expect(FortnoxUrl.base_url.uri).to eq URI('https://api.fortnox.se/3') }

  specify { expect(FortnoxUrl.build(path_suffix: 'foo').uri).to eq URI('https://api.fortnox.se/3/foo') }

  specify { expect(FortnoxUrl.build(path_suffix: '/foo').uri).to eq URI('https://api.fortnox.se/3/foo') }

  specify { expect(FortnoxUrl.build(path_suffix: 'foo', params: { a: 'b' }).uri).to eq URI('https://api.fortnox.se/3/foo?a=b') }

end