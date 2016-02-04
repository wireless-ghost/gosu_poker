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
    @active_player_id = ""
    @players = {}
    #Thread.new { main }
  end

  def main
    Thread.new {
      while(true) do 
        #if @connections[:clients].count != 2
        #  sleep 2
        #  next
        #end
        if @connections[:clients].count == 2
          case @cur_state
          when STATES::WAIT
            #@cur_state = STATES::DEAL
            #@deck = Deck.new
            #player.clear
          when STATES::DEAL
            pp "DEALING NIGA"
            @connections[:clients].each do |id, client|
              player = @players[id]
              player.add_cards(@deck.deal(2))
              @players[id] = player
              client.puts player.to_json
            end
            pp "DEALT"
            #player.add_cards(@deck.deal(2))
            @cur_state = STATES::PRE_FLOP
          when STATES::PRE_FLOP
            pp "PRE_FLOP"
            wait_for_players
            @cur_state = STATES::FLOP
          when STATES::FLOP
            pre_flop_cards = @deck.deal(3)
            @connections[:clients].each do |id, client|
              player = @players[id]
              player.add_table_cards(pre_flop_cards)
              @players[id] = player
              client.puts player.to_json
            end
            wait_for_players
            @cur_state = STATES::TURN
          when STATES::TURN
            flop_card = @deck.deal(1)
            @connections[:clients].each do |id, client|
              player = @players[id]
              player.add_table_cards(flop_card)
              @players[id] = player
              client.puts player.to_json
            end
            #player.add_table_cards(@deck.deal(1))
            wait_for_players
            @cur_state = STATES::RIVER
          when STATES::RIVER
            flop_card = @deck.deal(1)
            @connections[:clients].each do |id, client|
              player = @players[id]
              player.add_table_cards(flop_card)
              @players[id] = player
              client.puts player.to_json
            end

            #player.add_table_cards(@deck.deal(1))
            @cur_state = STATES::WAIT
          end
        end
      end
    }
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
          if player.id == other_name || client == other_client
            client.puts "This username already exists"
            Thread.kill self
          end
        end
        #pp player
        #pp player.card_count
        #    @cur_state = STATES::DEAL
        #if (player.card_count < 5)
        #     player.add_cards(@deck.deal(2))
        #end
        #   @cur_state = STATES::PRE_FLOP
        @connections[:clients][player.id] = client
        @players[player.id] = player
        #client.puts player.to_json
        if @connections[:clients].count == 1
          @active_player_id = player.id
        end

        if @connections[:clients].count == 2
          #@active_player_id = @connections[:clients][0]
          @cur_state = STATES::DEAL
          pp "READY"
          main
        end

        #client.puts "Connection established. Thank you for joining"
        listen_user_messages(player.id, client)
      end
    }.join
  end

  def listen_user_messages(username, client)
    puts "LISTEN AGAIN"
    loop {
      msg = client.gets
      player = Player.new(msg)
      if (player.id == @active_player_id)
        @players[player.id] = player
        puts "OK WE"
        pp player
      end
=begin
      if player.action == 'check'
        case @cur_state
        when STATES::WAIT
          #@cur_state = STATES::DEAL
          #@deck = Deck.new
          #player.clear
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
      end
      #if (player.card_count < 5)
      #  player.add_cards(@deck.deal(1))
      #end
      #pp player
      client.puts player.to_json
=end
      #@connections[:clients].each do |other_name, other_client|
      #  unless other_name == username
      #    #other_client.puts "#{username}: #{msg}"
      #  end
      #end
    }
  end

  def reset_players
    @connections[:clients].each do |id, client|
      player = @players[id]
      player.status = "wait"
      @players[id] = player
      client.puts player.to_json
    end
  end

  def wait_for_players
    reset_players
    @connections[:clients].each do |id, client|
      @active_player_id = id
      while(true) do
        if (@players[id].status == "done")
          break;
        end
      end
    end
  end
end

Server.new(2000, "localhost").run
