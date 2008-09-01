require 'digest/md5'
require 'time'

module PintoBeans
  class RackHandler
    def call(env)
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

      if env['HTTP_IF_NONE_MATCH'] != etag
        return [
          300,
          {
            'Cache-Control' => 'max-age=21600',
            'ETag' => etag,
            'Allow' => 'GET, HEAD, OPTIONS',
            'Content-Language' => 'en',
            'Content-Type' => 'application/xhtml+xml; charset=UTF-8',
            'Last-Modified' => Time.now.httpdate,
            'Expires' => (Time.now + (60 * 60 * 6)).httpdate
          },
          response_body
        ]
      end

      [304, {'ETag' => etag}, response_body]
    end
  end
end
