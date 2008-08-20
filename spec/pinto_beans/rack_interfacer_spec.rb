$LOAD_PATH << 'lib'
require 'pinto_beans'

$DEBUG = true
require 'spec/fake/router'

describe 'PintoBeans::RackInterfacer.call' do
  it 'should return correct array to env' do
    env = Rack::MockRequest.env_for('http://pinto.jp/call')

    array = PintoBeans::RackInterfacer.new.call(env)
    array[0].should == 200
    array[1].should == {}
    array[2].should == 'http://pinto.jp/call'
  end
end

describe 'PintoBeans::RackInterfacer.transform_request' do
  it 'should return correct request to env' do
    env = Rack::MockRequest.env_for('http://pinto.jp/transform_request?a=b')

    request = PintoBeans::RackInterfacer.new.transform_request(env)
    request.uri.should == 'http://pinto.jp/transform_request?a=b'
    request.method.should == 'GET'
    request.headers.should == {
      'SERVER_NAME' => 'pinto.jp',
      'PATH_INFO' => '/transform_request',
      'SCRIPT_NAME' => '',
      'SERVER_PORT' => '80',
      'QUERY_STRING' => 'a=b',
      'REQUEST_METHOD' => 'GET'
    }
    request.cookies.should == {}
    request.query_strings.should == {'a' => 'b'}
    request.form_data.should == {}
  end
end

describe 'PintoBeans::RackInterfacer.delegate_to_router' do
  it 'should return correct response to request' do
    request = PintoBeans::HttpRequest.new
    request.uri = 'http://pinto.jp/delegate_to_router'

    response = PintoBeans::RackInterfacer.new.delegate_to_router(request)
    response.status_code.should == 200
    response.headers.should == {}
    response.body.should == 'http://pinto.jp/delegate_to_router'
  end
end

describe 'PintoBeans::RackInterfacer.transform_response' do
  it 'should return correct array to response' do
    response = PintoBeans::HttpResponse.new
    response.status_code = 200
    response.headers = {}
    response.body = 'http://pinto.jp/transform_response'

    array = PintoBeans::RackInterfacer.new.transform_response(response)
    array[0].should == 200
    array[1].should == {}
    array[2].should == 'http://pinto.jp/transform_response'
  end
end
