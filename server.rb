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
    @pot = 0
    @all_folded = false
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
            @all_folded = false
            @pot = 0
            @connections[:clients].each do |id, client|
              @players[id].clear
              client.puts @players[id].to_json
            end

            sleep(8)
          when STATES::DEAL
            @pot = 0
            @connections[:clients].each do |id, client|
              player = @players[id]
              player.add_cards(@deck.deal(2))
              @players[id] = player
              client.puts player.to_json
            end
            @cur_state = STATES::PRE_FLOP
          when STATES::PRE_FLOP
            wait_for_players
            @cur_state = STATES::FLOP unless @all_folded
          when STATES::FLOP
            play(3)
            @cur_state = STATES::TURN unless @all_folded
          when STATES::TURN
            wait_for_players
            play(1)
            pp "FOLDED #{@all_folded}"
            @cur_state = STATES::RIVER unless @all_folded
          when STATES::RIVER
            player.add_table_cards(@deck.deal(1))
            play(1)
            @cur_state = STATES::FINALIZE
          when STATES::FINALIZE
            pp "=============================================="
            check_winner 
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

  def listen_user_messages(id, client)
    loop {
      msg = client.gets
      player = Player.new(msg)
      #pp player, player.id, @active_player_id
      if (player.id == @active_player_id)
        @players[player.id] = player
        if player.action == "fold"
          folds_counter = 1
          pp "FOLD"
          @connections[:clients].each do |id2, client|
            if id2 != player.id && @players[id2].action == "fold"
              folds_counter += 1
            end
          end
          pp folds_counter
          if folds_counter == @connections[:clients].count - 1
            pp "folders"
            @connections[:clients].each do |id, client|
              if @players[id].action != "fold"
                @players[id].add_money @pot
                @players[id].finish_game(:win)
              else
                @players[id].finish_game
              end
              client.puts @players[id].to_json
            end
            @cur_state = STATES::WAIT
            @all_folded = true
          end
        end
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

  def play(cards_to_deal)
    cards = @deck.deal(cards_to_deal)
    @connections[:clients].each do |id, client|
      player = @players[id]
      player.add_table_cards(cards)
      @players[id] = player
      client.puts player.to_json
    end
    wait_for_players
  end

  def wait_for_players
    #reset_players
    #pp "WAITIN"
    bet = 0
    clients_bet_counter = 0
    loop do
      @connections[:clients].each do |id, client|
        break if @all_folded
        @active_player_id = id
        @players[id].status = "wait"
        @players[id].active = "yes"
        #pp "SET #{@players[id]} status to wait"
        client.puts @players[id].to_json
        pp "WAITING FOR #{@players[id].name}"
        while(true) do
          if @players[id].status == "done"
            if @players[id].action == "check" && bet == 0
              break
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
            elsif @players[id].action == "fold"
              break
            end
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
