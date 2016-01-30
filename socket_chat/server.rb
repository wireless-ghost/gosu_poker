require 'socket'

class Server
  def initialize(port, ip)
    @server = TCPServer.open( ip, port )
    @connections = {}
    @rooms = {}
    @clients = {}
    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
  end

  def run
    loop {
      Thread.start(@server.accept) do |client|
        nick = client.gets.chomp.to_sym
        puts nick
        @connections[:clients].each do |other_name, other_client|
          if nick == other_name || client == other_client
            client.puts "This username already exists"
            Thread.kill self
          end
        end
        puts "#{nick} #{client}"
        @connections[:clients][nick] = client
        client.puts "Connection established. Thank you for joining"
        listen_user_messages(nick, client)
      end
    }.join
  end

  def listen_user_messages(username, client)
    puts username, client
    loop {
      msg = client.gets.chomp
      puts msg
      @connections[:clients].each do |other_name, other_client|
        unless other_name == username
          other_client.puts "#{username}: #{msg}"
        end
      end
    }
  end
end

Server.new(2000, "localhost").run

