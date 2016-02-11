require 'socket'
require './player.rb'
require './deck.rb'
require 'deep_clone'

module STATES
  WAIT = 0,
    DEAL = 1,
    PRE_FLOP = 2,
    FLOP = 3,
    TURN = 4,
    RIVER = 5,
    FINALIZE = 6
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
            @cur_state = STATES::DEAL
            @deck = Deck.new
            #player.clear
            @connections[:clients].each do |id, client|
              @players[id].clear
              client.puts @players[id].to_json
            end

            sleep(8)
          when STATES::DEAL
            @pot = 0
            pp "DEALING NIGA"
            @connections[:clients].each do |id, client|
              player = @players[id]
              player.add_cards(@deck.deal(2))
              @players[id] = player
              #pp player.name
              #pp player
              #pp "GIVE TWO CARDS TO #{player.name}"
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
              pp "RIVER"
              player = @players[id]
              player.add_table_cards(flop_card)
              pp "addd #{player.name}"
              @players[id] = player
              client.puts player.to_json
            end
            wait_for_players
            #player.add_table_cards(@deck.deal(1))
            @cur_state = STATES::FINALIZE
          when STATES::FINALIZE
            pp "=============================================="
            check_winner 
            #while(true)
              @cur_state = STATES::WAIT
            #end
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

        @connections[:clients][player.id] = client
        @players[player.id] = player

        if @connections[:clients].count == 2
          @connections[:clients].each do |id, cl|
            other = @players[id]
            other.other_players = DeepClone.clone( @players ).select { |key, value| key != id }.values.each { |pl| pl.other_players = [] }
            #other.other_players = other.other_players.clone.values.each { |pl| pl.other_players = [] }
            @players[id] = other
            pp "adding others for #{other.name}"
            #pp @players[id]
            #     pp "SHOWING FIRST PLAYER"
            #     pp @players.first
            cl.puts other.to_json
          end
          @cur_state = STATES::DEAL
          main
        end

        #client.puts "Connection established. Thank you for joining"
        listen_user_messages(player.id, client)
      end
    }.join
  end

  def listen_user_messages(username, client)
    loop {
      msg = client.gets
      player = Player.new(msg)
      #pp player, player.id, @active_player_id
      if (player.id == @active_player_id)
        @players[player.id] = player
      end
    }
  end

  def check_winner
    hands = {}
    @players.each do |id, player|
      hands[id] = player.best_hand
    end
    #pp "RACETE GORE"
    #pp hands
    winners = hands.select { |id, value| value == hands.values.max }
    #pp winners
    @split_amount = @pot / winners.count
    #pp @split_amount
    @clients.each do |id, client|
      if winners.keys.include? id
        @players[id].add_money @split_amount
        @players[id].finish_game(:win)
      else
        @players[id].finish_game
      end
      client.puts @players[id].to_json
    end
    #while(true)

    #end
    #winners.each do |id, _|
    #  @players[id].add_money @split_amount
    #  @connections[:clients][id].puts @players[id].to_json
    #end
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
    #reset_players
    #pp "WAITIN"
    bet = 0
    clients_bet_counter = 0
    loop do
      @connections[:clients].each do |id, client|
        @active_player_id = id
        @players[id].status = "wait"
        @players[id].active = "yes"
        #pp "SET #{@players[id]} status to wait"
        client.puts @players[id].to_json
        pp "WAITING FOR #{@players[id].name}"
        while(true) do
          if @players[id].status == "done"
            if @players[id].action == "check" && bet == 0
              break;
            elsif @players[id].action == "bet"
              if bet == 0
                bet = @players[id].bet_amount
                pp bet
              end
              if bet == @players[id].bet_amount
                clients_bet_counter += 1
                @pot += bet
                pp @pot
                break
              end
            end
            #@players[id].status = "wait"
            #client.puts @players[id].to_json
          end
        end
        @players[id].active = "no"
        @players[id].status = "wait"
        client.puts @players[id].to_json
      end

      break if clients_bet_counter == @connections[:clients].count || bet == 0 
    end
  end
end

Server.new(2000, "localhost").run
