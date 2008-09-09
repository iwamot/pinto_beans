require 'digest/md5'
require 'time'

module PintoBeans
  module SpecHelper
    def self.url
      "http://#{$spec[:host]}#{$spec[:path]}"
    end
  end
end

share_examples_for 'English resource' do
  it 'should return "en" in Content-Language header' do
    @response['Content-Language'].should == 'en'
  end
end

share_examples_for 'platonic URI' do
  it 'should return 300 for status code' do
    @response.code.should == '300'
  end

  if @method == 'GET'
    it 'should return MD5 of response body in ETag header' do
      @response['ETag'].should ==
            '"' + Digest::MD5.hexdigest(@response.body) + '"'
    end
  end

  it_should_behave_like 'English resource'

  it 'should return past HTTP-date time in Last-Modified header' do
    Time.httpdate(@response['Last-Modified']).should <= Time.now
  end
end

share_examples_for 'XHTML representation' do
  it 'should return "application/xhtml+xml; charset=UTF-8" in Content-Type header' do
    @response['Content-Type'].should == 'application/xhtml+xml; charset=UTF-8'
  end
end

share_examples_for 'cacheable' do
  it "should return \"max-age=#{$spec[:expires]}\" in Cache-Control header" do
    @response['Cache-Control'].should == "max-age=#{$spec[:expires]}"
  end

  it "should return #{$spec[:expires]} seconds later than Last-Modified in Expires header" do
    Time.httpdate(@response['Expires']).should ==
          Time.httpdate(@response['Last-Modified']) + $spec[:expires]
  end
end

share_examples_for 'allow specified methods' do
  it "should return \"#{$spec[:allowed_methods]}\" in Allow header" do
    @response['Allow'].should == $spec[:allowed_methods]
  end
end

share_examples_for 'no content' do
  it "should not return response body" do
    @response.body.to_s.should == ''
  end
end





share_examples_for 'Not Modified' do
  it 'should return 304 for status code' do
    @response.code.should == '304'
  end

  it 'should return the same ETag header' do
    @response['ETag'].should == @etag
  end

  it 'should not return other entity headers' do
    @response.key?('Allow').should be_false
    @response.key?('Content-Encoding').should be_false
    @response.key?('Content-Length').should be_false
    @response.key?('Content-Location').should be_false
    @response.key?('Content-MD5').should be_false
    @response.key?('Content-Range').should be_false
    @response.key?('Content-Type').should be_false
    @response.key?('Expires').should be_false
    @response.key?('Last-Modified').should be_false
  end
end

share_examples_for 'Precondition Failed' do
  it 'should return 412 for status code' do
    @response.code.should == '412'
  end

  it_should_behave_like 'allow specified methods'
  it_should_behave_like 'English resource'

  if $spec[:content_type] == 'XHTML'
    it_should_behave_like 'XHTML representation'
  end
end

share_examples_for 'GET OK' do
  if $spec[:multiple_choices]
    it_should_behave_like 'platonic URI'
  end

  if $spec[:content_type] == 'XHTML'
    it_should_behave_like 'XHTML representation'
  end

  if $spec[:expires] > 0
    it_should_behave_like 'cacheable'
  end

  it_should_behave_like 'allow specified methods'
end

share_examples_for 'HEAD OK' do
  if $spec[:multiple_choices]
    it_should_behave_like 'platonic URI'
  end

  if $spec[:content_type] == 'XHTML'
    it_should_behave_like 'XHTML representation'
  end

  if $spec[:expires] > 0
    it_should_behave_like 'cacheable'
  end

  it_should_behave_like 'allow specified methods'
  it_should_behave_like 'no content'
end









describe PintoBeans::SpecHelper.url do
  before(:all) do
    @http = Net::HTTP.new($spec[:host])
  end

  # GET
  if $spec[:allowed_methods].include? 'GET'
    describe 'when GET' do
      before(:all) do
        @method = 'GET'
        @response = @http.get($spec[:path])
      end

      describe 'non-conditional' do
        it_should_behave_like 'GET OK'
      end

      describe 'with valid If-None-Match header' do
        before(:all) do
          @etag = @response['ETag']
          @response = @http.get($spec[:path], 'If-None-Match' => @etag)
        end

        it_should_behave_like 'Not Modified'
      end

      describe 'with invalid If-None-Match header' do
        before(:all) do
          etag = @response['ETag']
          @response = @http.get($spec[:path], 'If-None-Match' => etag + 'zzz')
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with If-None-Match header including valid entity tag and invalid one' do
        before(:all) do
          @etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-None-Match' => '"invalid", ' + @etag)
        end

        it_should_behave_like 'Not Modified'
      end

      describe 'with If-None-Match header including only invalid entity tags' do
        before(:all) do
          etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-None-Match' => '"invalid", zzz' + etag)
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with "*" If-None-Match header' do
        before(:all) do
          @etag = @response['ETag']
          @response = @http.get($spec[:path], 'If-None-Match' => '*')
        end

        it_should_behave_like 'Not Modified'
      end

      describe 'with valid RFC 1123 time If-Modified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          @etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-Modified-Since' => last_modified)
        end

        it_should_behave_like 'Not Modified'
      end

      describe 'with valid RFC 1036 time If-Modified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          last_modified_rfc1036 = Time.httpdate(last_modified).utc.
                strftime('%A, %d-%b-%y %H:%M:%S GMT')
          @etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-Modified-Since' => last_modified_rfc1036)
        end

        it_should_behave_like 'Not Modified'
      end

      describe 'with valid asctime() formatted time If-Modified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          last_modified_asctime = Time.httpdate(last_modified).utc.
                strftime('%a %b ' +
                         Time.httpdate(last_modified).day.to_s.rjust(2) +
                         ' %H:%M:%S %Y')
          @etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-Modified-Since' => last_modified_asctime)
        end

        it_should_behave_like 'Not Modified'
      end

      describe 'with advanced time If-Modified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          invalid_time = Time.httpdate(last_modified).utc.succ.httpdate
          @response = @http.get($spec[:path],
                'If-Modified-Since' => invalid_time)
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with delayed time If-Modified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          invalid_time = Time.httpdate(last_modified).utc.succ.httpdate
          @response = @http.get($spec[:path],
                'If-Modified-Since' => invalid_time)
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with malformed time If-Modified-Since header' do
        before(:all) do
          @response = @http.get($spec[:path], 'If-Modified-Since' => 'zzz')
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with valid If-None-Match header and valid If-Modified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          @etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-None-Match'     => @etag,
                'If-Modified-Since' => last_modified)
        end

        it_should_behave_like 'Not Modified'
      end

      describe 'with invalid If-None-Match header and valid If-Modified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-None-Match'     => etag + 'zzz',
                'If-Modified-Since' => last_modified)
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with valid If-None-Match header and invalid If-Modified-Since header' do
        before(:all) do
          last_modified = Time.httpdate(@response['Last-Modified']).utc
          etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-None-Match'     => etag,
                'If-Modified-Since' => last_modified.succ.httpdate)
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with invalid If-None-Match header and invalid If-Modified-Since header' do
        before(:all) do
          last_modified = Time.httpdate(@response['Last-Modified']).utc
          etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-None-Match'     => etag + 'zzz',
                'If-Modified-Since' => last_modified.succ.httpdate)
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with valid If-Match header' do
        before(:all) do
          etag = @response['ETag']
          @response = @http.get($spec[:path], 'If-Match' => etag)
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with invalid If-Match header' do
        before(:all) do
          etag = @response['ETag']
          @response = @http.get($spec[:path], 'If-Match' => etag + 'zzz')
        end

        it_should_behave_like 'Precondition Failed'
      end

      describe 'with If-Match header including valid entity tag and invalid one' do
        before(:all) do
          etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-Match' => '"invalid", ' + etag)
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with If-Match header including only invalid entity tags' do
        before(:all) do
          etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-Match' => '"invalid", zzz' + etag)
        end

        it_should_behave_like 'Precondition Failed'
      end

      describe 'with "*" If-Match header' do
        before(:all) do
          @response = @http.get($spec[:path], 'If-Match' => '*')
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with valid RFC 1123 time If-Unmodified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          @response = @http.get($spec[:path],
                'If-Unmodified-Since' => last_modified)
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with valid RFC 1036 time If-Unmodified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          last_modified_rfc1036 = Time.httpdate(last_modified).utc.
                strftime('%A, %d-%b-%y %H:%M:%S GMT')
          @response = @http.get($spec[:path],
                'If-Unmodified-Since' => last_modified_rfc1036)
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with valid asctime() formatted time If-Unmodified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          last_modified_asctime = Time.httpdate(last_modified).utc.
                strftime('%a %b ' +
                         Time.httpdate(last_modified).day.to_s.rjust(2) +
                         ' %H:%M:%S %Y')
          @response = @http.get($spec[:path],
                'If-Unmodified-Since' => last_modified_asctime)
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with advanced time If-Unmodified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          invalid_time = Time.httpdate(last_modified).utc.succ.httpdate
          @response = @http.get($spec[:path],
                'If-Unmodified-Since' => invalid_time)
        end

        it_should_behave_like 'Precondition Failed'
      end

      describe 'with delayed time If-Unmodified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          invalid_time = Time.httpdate(last_modified).utc.succ.httpdate
          @response = @http.get($spec[:path],
                'If-Unmodified-Since' => invalid_time)
        end

        it_should_behave_like 'Precondition Failed'
      end

      describe 'with malformed time If-Unmodified-Since header' do
        before(:all) do
          @response = @http.get($spec[:path], 'If-Unmodified-Since' => 'zzz')
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with valid If-Match header and valid If-Unmodified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-Match'            => etag,
                'If-Unmodified-Since' => last_modified)
        end

        it_should_behave_like 'GET OK'
      end

      describe 'with invalid If-Match header and valid If-Unmodified-Since header' do
        before(:all) do
          last_modified = @response['Last-Modified']
          etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-Match'            => etag + 'zzz',
                'If-Unmodified-Since' => last_modified)
        end

        it_should_behave_like 'Precondition Failed'
      end

      describe 'with valid If-Match header and invalid If-Unmodified-Since header' do
        before(:all) do
          last_modified = Time.httpdate(@response['Last-Modified']).utc
          etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-Match'            => etag,
                'If-Unmodified-Since' => last_modified.succ.httpdate)
        end

        it_should_behave_like 'Precondition Failed'
      end

      describe 'with invalid If-Match header and invalid If-Unmodified-Since header' do
        before(:all) do
          last_modified = Time.httpdate(@response['Last-Modified']).utc
          etag = @response['ETag']
          @response = @http.get($spec[:path],
                'If-Match'            => etag + 'zzz',
                'If-Unmodified-Since' => last_modified.succ.httpdate)
        end

        it_should_behave_like 'Precondition Failed'
      end
    end
  end

  # HEAD
  if $spec[:allowed_methods].include? 'HEAD'
    describe 'when HEAD' do
      before(:all) do
        @method = 'HEAD'
        @response = @http.head($spec[:path])
      end

      describe 'non-conditional' do
        it_should_behave_like 'HEAD OK'
      end



    end
  end

  # OPTIONS
  if $spec[:allowed_methods].include? 'OPTIONS'

  end
end
