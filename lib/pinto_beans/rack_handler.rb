module PintoBeans
  class RackHandler
    def call(env)
      [
        300,
        {
          'Content-Type' => 'text/html; charset=UTF-8'
        },
        'テスト'
      ]
    end
  end
end
