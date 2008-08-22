$LOAD_PATH << 'lib'
require 'pinto_beans'

describe 'PintoBeans::RackServer.call' do
  it "should:
        1. transform request,
        2. call PintoBeans::Router.route with it,
        3. transform router's response,
        4. and return it" do

    mock_response = PintoBeans::HttpResponse.new
    mock_response.status_code = 200
    mock_response.headers     = {'Content-Type' => 'text/plain'}
    mock_response.body        = 'dummy'

    PintoBeans::Router.should_receive(:route) do |request|
      request.uri.should == 'http://pinto.jp/dummy'
      mock_response
    end.once

    env = Rack::MockRequest.env_for('http://pinto.jp/dummy')
    response = PintoBeans::RackServer.new.call(env)
    response[0].should == 200
    response[1].should == {'Content-Type' => 'text/plain'}
    response[2].should == 'dummy'
  end
end
