#require 'digest/md5'
require 'time'

module PintoBeans
  class RackHandler
    def call(env)
      [
        503,
        {
          'Content-Type' => 'application/xhtml+xml; charset=UTF-8',
          'Content-Language' => 'en',
          'ETag' => '"xxxx"',
          'Last-Modified' => Time.now.utc.httpdate
        },
        '503 Service Unavailable'
      ]

=begin
      response_body = <<END
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title>Pinto</title>
</head>
<body>
<h1>Pinto</h1>
</body>
</html>
END

      etag = '"' + Digest::MD5.hexdigest(response_body) + '"'
      last_modified = Time.utc(2008, 8, 1, 12, 34, 56)

      if_modified_since = begin
                            Time.httpdate(env['HTTP_IF_MODIFIED_SINCE'])
                          rescue
                            nil
                          end
      if_unmodified_since = begin
                              Time.httpdate(env['HTTP_IF_UNMODIFIED_SINCE'])
                            rescue
                              nil
                            end

      if (!env['HTTP_IF_MATCH'].nil? &&
          !env['HTTP_IF_MATCH'].to_s.split(/,\s*/).include?(etag) &&
          env['HTTP_IF_MATCH'] != '*') ||
         (!if_unmodified_since.nil? &&
          if_unmodified_since != last_modified)
        return [
          412,
          {
            'Allow' => 'GET, HEAD, OPTIONS',
            'Content-Language' => 'en',
            'Content-Type' => 'application/xhtml+xml; charset=UTF-8'
          },
          response_body
        ]
      end

      if (!env['HTTP_IF_NONE_MATCH'].nil? || !if_modified_since.nil?) &&
         (env['HTTP_IF_NONE_MATCH'].nil? ||
          env['HTTP_IF_NONE_MATCH'].to_s.split(/,\s*/).include?(etag) ||
          env['HTTP_IF_NONE_MATCH'] == '*') &&
         (if_modified_since.nil? ||
          if_modified_since == last_modified)
        return [304, {'ETag' => etag}, response_body]
      end

      [
        300,
        {
          'Cache-Control' => 'max-age=21600',
          'ETag' => etag,
          'Allow' => 'GET, HEAD, OPTIONS',
          'Content-Language' => 'en',
          'Content-Type' => 'application/xhtml+xml; charset=UTF-8',
          'Last-Modified' => last_modified.httpdate,
          'Expires' => (last_modified + (60 * 60 * 6)).httpdate
        },
        response_body
      ]
=end
    end
  end
end
