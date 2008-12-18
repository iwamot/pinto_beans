module PintoBeans
  class Cluster 
    def initialize(opt_parser, daemons, pathname, server_factory)
      @opt_parser = opt_parser
      @daemons = daemons
      @pathname = pathname
      @server_factory = server_factory
    end

    def run(argv)
      port   = 3000
      number = 1
      log_output = false

      @opt_parser.banner =  "Usage:\n"
      @opt_parser.banner << "     pinto_cluster start [options]   Start servers with forking\n"
      @opt_parser.banner << "     pinto_cluster run [-p,--port]   Start a server without forking\n"
      @opt_parser.banner << "     pinto_cluster stop              Stop servers\n"
      @opt_parser.banner << "     pinto_cluster status            Show status\n"
      @opt_parser.separator('Options:')
      @opt_parser.on('-p', '--port PORT', Integer, 'First port (default: 3000)') do |p|
        port = p
      end
      @opt_parser.on('-n', '--number NUMBER', Integer, 'Number of servers (default: 1)') do |n|
        number = n
      end
      @opt_parser.on('-l', '--log', TrueClass, 'Output log') do |l|
        log_output = l
      end

      command = argv.first
      unless ['start', 'run', 'stop', 'status'].include?(command)
        puts @opt_parser
        exit
      end

      begin
        @opt_parser.parse(argv)
      rescue
        puts @opt_parser
        exit
      end

      app_dir = @pathname.pwd
      daemon_options = {
        :ARGV       => [command],
        :dir_mode   => :normal,
        :dir        => app_dir + 'run',
        :multiple   => true,
        :log_output => log_output
      }

      server = @server_factory.create(app_dir)
      case command
      when 'start'
        number.times do |n|
          @daemons.call(daemon_options) do
            server.run(port + n)
          end
        end
      when 'run', 'stop', 'status'
        @daemons.run_proc('proc', daemon_options) do
          server.run(port)
        end
      end
    end
  end
end
