require 'socket'
require './player.rb'
require './deck.rb'

module STATES
  WAIT = 0,
  DEAL = 1,
  PRE_FLOP = 2,
  FLOP = 3,
  TURN = 4,
  RIVER = 5
end

class Server
  def initialize(port, ip)
    @server = TCPServer.open( ip, port )
    @connections = {}
    @rooms = {}
    @clients = {}
    @connections[:server] = @server
    @connections[:clients] = @clients
    @deck = Deck.new
    @cur_state = STATES::WAIT
  end

  def run
    loop {
      Thread.start(@server.accept) do |client|
        if @connections[:clients].count == 4
          Thread.kill self
        end
        msg = client.gets.chomp
        #puts nick
        puts msg
        player = Player.new(msg)
        @connections[:clients].each do |other_name, other_client|
          if player.name.to_sym == other_name || client == other_client
            client.puts "This username already exists"
            Thread.kill self
          end
        end
        #pp player
        #pp player.card_count
        @cur_state = STATES::DEAL
        #if (player.card_count < 5)
        player.add_cards(@deck.deal(2))
        #end
        @cur_state = STATES::PRE_FLOP
        @connections[:clients][player.name.to_sym] = client
        client.puts player.to_json
        #client.puts "Connection established. Thank you for joining"
        listen_user_messages(player.name.to_sym, client)
      end
    }.join
  end

  def listen_user_messages(username, client)
    puts "LISTEN AGAIN"
    loop {
      msg = client.gets
      #pp "JOKER"
      #pp msg
      player = Player.new(msg)
      #pp "STATE: #{@cur_state}"
      case @cur_state
      when STATES::WAIT
        @cur_state = STATES::DEAL
        @deck = Deck.new
        player.clear
      when STATES::DEAL
        player.add_cards(@deck.deal(2))
        @cur_state = STATES::PRE_FLOP
      when STATES::PRE_FLOP
        pp "PRE_FLOP"
        @cur_state = STATES::FLOP
      when STATES::FLOP
        player.add_table_cards(@deck.deal(3))
        @cur_state = STATES::TURN
      when STATES::TURN
        player.add_table_cards(@deck.deal(1))
        @cur_state = STATES::RIVER
      when STATES::RIVER
        player.add_table_cards(@deck.deal(1))
        @cur_state = STATES::WAIT
      end
      #if (player.card_count < 5)
      #  player.add_cards(@deck.deal(1))
      #end
      #pp player
      client.puts player.to_json
      #@connections[:clients].each do |other_name, other_client|
      #  unless other_name == username
      #    #other_client.puts "#{username}: #{msg}"
      #  end
      #end
    }
  end
end

Server.new(2000, "localhost").run
