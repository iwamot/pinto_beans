module PintoBeans
  class RackHandler
    def call(env)
      [
        200,
        {'Content-Type' => 'text/plain; charset=UTF-8'},
        'Hello World!'
      ] 
    end
  end
end

