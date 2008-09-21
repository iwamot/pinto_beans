module PintoBeans
  module Spec
    class Base
      def initialize
        @group = ::Spec::Example::ExampleGroup.new('main')
        self.define
      end

      def run
        uri = URI.parse(@uri)
        uri_group = @group.describe @uri do nil end
        self.test_service_unavailable(uri, uri_group)
        self.test_method_not_allowed(uri, uri_group)
        self.test_precondition_failed(uri, uri_group)
#        self.test_not_modified(uri, uri_group)
#        self.test_internal_server_error(uri, uri_group)
      end

      def test_service_unavailable(uri, group)
        return unless self.respond_to?(:service_unavailable_begin)

        self.service_unavailable_begin
        begin
          @allowed_methods.each do |method|
            sub_group = group.describe "when it's called by #{method} under service_unavailable" do
              before(:all) do
                http = Net::HTTP.new(uri.host, uri.port)
                @response = http.send(method.downcase, uri.path)
              end

              it 'should return 503 as status code' do
                @response.code.should == '503'
              end
            end

            if self.respond_to?(:service_unavailable_header)
              self.service_unavailable_header(sub_group)
            end

            if self.respond_to?(:service_unavailable_body) &&
                  !['HEAD', 'OPTIONS'].include?(method)
              self.service_unavailable_body(sub_group)
            end
          end
        ensure
          if self.respond_to? :service_unavailable_end
            self.service_unavailable_end
          end
        end
      end

      def test_method_not_allowed(uri, group)
        ['GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'OPTIONS'].each do |method|
          next if @allowed_methods.include?(method)

          sub_group = group.describe "when it's called by #{method}" do
            before(:all) do
              http = Net::HTTP.new(uri.host, uri.port)
              if ['POST', 'PUT'].include?(method)
                @response = http.send(method.downcase, uri.path, '')
              else
                @response = http.send(method.downcase, uri.path)
              end
            end

            it 'should return 405 as status code' do
              @response.code.should == '405'
            end
          end

          if self.respond_to?(:method_not_allowed_header)
            self.method_not_allowed_header(sub_group)
          end

          if self.respond_to?(:method_not_allowed_body) &&
                !['HEAD', 'OPTIONS'].include?(method)
            self.method_not_allowed_body(sub_group)
          end
        end
      end

      def test_precondition_failed(uri, group)
        @allowed_methods.each do |method|
          test_if_match_etag_invalid(uri, group, method)
          test_if_match_etags_invalid(uri, group, method)
=begin
          test_if_unmodified_since_malformed(uri, group, method)
          test_if_unmodified_since_advanced(uri, group, method)
          test_if_unmodified_since_delayed(uri, group, method)
=end
          # more
        end
      end

      def test_if_match_etag_invalid(uri, group, method)
        sub_group = group.describe "when it's called by #{method} with invalid If-Match entity tag" do
          before(:all) do
            http = Net::HTTP.new(uri.host, uri.port)
            @get_response = http.get(uri.path)

            header = {'If-Match' => @get_response['ETag'].to_s + 'a'}
            if ['POST', 'PUT'].include?(method)
              @response = http.send(method.downcase, uri.path, '', header)
            else
              @response = http.send(method.downcase, uri.path, header)
            end
          end

          it 'should return 412 as status code' do
            @response.code.should == '412'
          end
        end

        if self.respond_to?(:precondition_failed_header)
          self.precondition_failed_header(sub_group)
        end

        if self.respond_to?(:precondition_failed_body) &&
              !['HEAD', 'OPTIONS'].include?(method)
          self.precondition_failed_body(sub_group)
        end
      end

      def test_if_match_etags_invalid(uri, group, method)
        sub_group = group.describe "when it's called by #{method} with invalid If-Match entity tags" do
          before(:all) do
            http = Net::HTTP.new(uri.host, uri.port)
            @get_response = http.get(uri.path)

            header = {'If-Match' => @get_response['ETag'].to_s + 'a, a"a"'}
            if ['POST', 'PUT'].include?(method)
              @response = http.send(method.downcase, uri.path, '', header)
            else
              @response = http.send(method.downcase, uri.path, header)
            end
          end

          it 'should return 412 as status code' do
            @response.code.should == '412'
          end
        end

        if self.respond_to?(:precondition_failed_header)
          self.precondition_failed_header(sub_group)
        end

        if self.respond_to?(:precondition_failed_body) &&
              !['HEAD', 'OPTIONS'].include?(method)
          self.precondition_failed_body(sub_group)
        end
      end

=begin
      def test_valid_if_match(uri, group, method)
        multiple = @multiple

        sub_group = group.describe "when it's called by #{method} with valid If-Match header" do
          before(:all) do
            http = Net::HTTP.new(uri.host, uri.port)
            @get_response = http.get(uri.path)

            header = {'If-Match' => @get_response['ETag'].to_s}
            if ['POST', 'PUT'].include?(method)
              @response = http.send(method.downcase, uri.path, '', header)
            else
              @response = http.send(method.downcase, uri.path, header)
            end
          end

          if method == 'GET'
            code = multiple ? '300' : '200'
            it "should return #{code} as status code" do
              @response.code.should == code
            end
          end
        end

        test_header = method.downcase + '_ok_header'
        self.send(test_header, sub_group) if self.respond_to?(test_header)

        test_body = method.downcase + '_ok_header'
        self.send(test_body, sub_group) if self.respond_to?(test_body)
      end
=end
    end
  end
end
