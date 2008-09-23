require 'time'

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

        @allowed_methods.each do |method|
          spec = self
          sub_group = group.describe "when it's called by #{method} under service_unavailable" do
            before(:all) do
              spec.service_unavailable_begin
              @response = spec.request(uri, method)
            end

            if spec.respond_to?(:service_unavailable_end)
              after(:all) do
                spec.service_unavailable_end
              end
            end
          end

          self.test_response(sub_group, 503, method)
        end
      end

      def test_method_not_allowed(uri, group)
        ['GET', 'HEAD', 'POST', 'PUT', 'DELETE', 'OPTIONS'].each do |method|
          next if @allowed_methods.include?(method)

          spec = self
          sub_group = group.describe "when it's called by #{method}" do
            before(:all) do
              http = Net::HTTP.new(uri.host, uri.port)
              @response = spec.request(uri, method)
            end
          end

          self.test_response(sub_group, 405, method)
        end
      end

      def test_precondition_failed(uri, group)
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.get(uri.path)
        etag = response['ETag']
        last_modified = response['Last-Modified']

        @allowed_methods.each do |method|
          test_invalid_if_match_etag(uri, group, method, etag)
          test_invalid_if_match_etags(uri, group, method, etag)
          test_advanced_if_unmodified_since(uri, group, method, last_modified)
          test_delayed_if_unmodified_since(uri, group, method, last_modified)
          test_invalid_if_match_and_valid_if_unmodified_since(uri, group, method, etag, last_modified)
          test_valid_if_match_and_invalid_if_unmodified_since(uri, group, method, etag, last_modified)

          unless ['GET', 'HEAD'].include?(method)
            test_valid_if_none_match_etag(uri, group, method, etag)
            test_valid_if_none_match_etags(uri, group, method, etag)
            test_asterisk_if_none_match(uri, group, method, etag)
# 以下、未実装
            test_valid_rfc1123_if_modified_since(uri, group, method, last_modified)
            test_valid_rfc1036_if_modified_since(uri, group, method, last_modified)
            test_valid_asctime_if_modified_since(uri, group, method, last_modified)
            test_valid_if_none_match_and_valid_if_modified_since(uri, group, method, etag, last_modified)
          end
        end
      end

      def test_invalid_if_match_etag(uri, group, method, etag)
        return if etag.nil?

        spec = self
        sub_group = group.describe "when it's called by #{method} with invalid If-Match entity tag" do
          before(:all) do
            header = {'If-Match' => etag + 'a'}
            @response = spec.request(uri, method, header)
          end
        end

        self.test_response(sub_group, 412, method)
      end

      def test_invalid_if_match_etags(uri, group, method, etag)
        return if etag.nil?

        spec = self
        sub_group = group.describe "when it's called by #{method} with invalid If-Match entity tags" do
          before(:all) do
            header = {'If-Match' => etag + 'a, a"a"'}
            @response = spec.request(uri, method, header)
          end
        end

        self.test_response(sub_group, 412, method)
      end

      def test_advanced_if_unmodified_since(uri, group, method, last_modified)
        return if last_modified.nil?

        spec = self
        sub_group = group.describe "when it's called by #{method} with advanced If-Unmodified-Since" do
          before(:all) do
            advanced_time = Time.httpdate(last_modified).utc.succ.httpdate
            header = {'If-Unmodified-Since' => advanced_time}
            @response = spec.request(uri, method, header)
          end
        end

        self.test_response(sub_group, 412, method)
      end

      def test_delayed_if_unmodified_since(uri, group, method, last_modified)
        return if last_modified.nil?

        spec = self
        sub_group = group.describe "when it's called by #{method} with delayed If-Unmodified-Since" do
          before(:all) do
            delayed_time = (Time.httpdate(last_modified).utc - 1).httpdate
            header = {'If-Unmodified-Since' => delayed_time}
            @response = spec.request(uri, method, header)
          end
        end

        self.test_response(sub_group, 412, method)
      end

      def test_invalid_if_match_and_valid_if_unmodified_since(uri, group, method, etag, last_modified)
        return if etag.nil? || last_modified.nil?

        spec = self
        sub_group = group.describe "when it's called by #{method} with invalid If-Match and valid If-Unmodified-Since" do
          before(:all) do
            header = {'If-Match' => etag + 'a',
                      'If-Unmodified-Since' => last_modified}
            @response = spec.request(uri, method, header)
          end
        end

        self.test_response(sub_group, 412, method)
      end

      def test_valid_if_match_and_invalid_if_unmodified_since(uri, group, method, etag, last_modified)
        return if etag.nil? || last_modified.nil?

        spec = self
        sub_group = group.describe "when it's called by #{method} with invalid If-Match and valid If-Unmodified-Since" do
          before(:all) do
            advanced_time = Time.httpdate(last_modified).utc.succ.httpdate
            header = {'If-Match' => etag,
                      'If-Unmodified-Since' => advanced_time}
            @response = spec.request(uri, method, header)
          end
        end

        self.test_response(sub_group, 412, method)
      end

      def test_valid_if_none_match_etag(uri, group, method, etag)
        return if etag.nil?

        spec = self
        sub_group = group.describe "when it's called by #{method} with valid If-None-Match entity tag" do
          before(:all) do
            header = {'If-None-Match' => etag}
            @response = spec.request(uri, method, header)
          end
        end

        status_code = ['GET', 'HEAD'].include?(method) ? 304 : 412
        self.test_response(sub_group, status_code, method)
      end

      def test_valid_if_none_match_etags(uri, group, method, etag)
        return if etag.nil?

        spec = self
        sub_group = group.describe "when it's called by #{method} with valid If-None-Match entity tags" do
          before(:all) do
            header = {'If-None-Match' => etag + ', a"a"'}
            @response = spec.request(uri, method, header)
          end
        end

        status_code = ['GET', 'HEAD'].include?(method) ? 304 : 412
        self.test_response(sub_group, status_code, method)
      end

      def test_asterisk_if_none_match(uri, group, method, etag)
        return if etag.nil?

        spec = self
        sub_group = group.describe "when it's called by #{method} with \"*\" If-None-Match" do
          before(:all) do
            header = {'If-None-Match' => '*'}
            @response = spec.request(uri, method, header)
          end
        end

        status_code = ['GET', 'HEAD'].include?(method) ? 304 : 412
        self.test_response(sub_group, status_code, method)
      end

      def request(uri, method, header = {}, body = '')
        http = Net::HTTP.new(uri.host, uri.port)
        if ['POST', 'PUT'].include?(method)
          http.send(method.downcase, uri.path, body, header)
        else
          http.send(method.downcase, uri.path, header)
        end
      end

      def test_response(group, status_code, method)
        self.test_status_code(group, status_code)
        context = case status_code
                  when 304
                    'not_modified'
                  when 405
                    'method_not_allowed'
                  when 412
                    'precondition_failed'
                  when 503
                    'service_unavailable'
                  end
        self.test_header(group, context)
        self.test_body(group, context, method)
      end

      def test_status_code(group, expected)
        group.it "should return #{expected} as status code" do
          @response.code.should == expected.to_s
        end
      end

      def test_header(group, context)
        test_method = context + '_header'
        self.send(test_method, group) if self.respond_to?(test_method)
      end

      def test_body(group, context, method)
        return if ['HEAD', 'OPTIONS'].include?(method)
        test_method = context + '_body'
        self.send(test_method, group) if self.respond_to?(test_method)
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
