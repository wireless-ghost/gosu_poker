require 'json'
require "./poker_hand.rb"
require 'securerandom'
require 'deep_clone'
require 'pp'

class Player
  attr_reader :name, :money, :id, :poker_hand, :table_cards
  attr_accessor :action, :status, :other_players, :active, :bet_amount

  ACTIONS = [:check, :bet, :raise, :fold]

  def initialize(player_hash)
    player_hash = JSON.parse(player_hash)
    #pp player_hash
    @name, @money = player_hash["name"], player_hash["money"]
    @poker_hand = PokerHand.new([])
    @action = player_hash["action"] if player_hash["action"]
    @table_cards = PokerHand.new([])
    @poker_hand.add_from_json(player_hash["cards"]) if player_hash["cards"]
    @table_cards.add_from_json(player_hash["table_cards"]) if player_hash["table_cards"]
    @id = player_hash["id"] == nil ? SecureRandom.uuid : player_hash["id"]
    @status = player_hash["status"] || "wait"
    #pp player_hash["other_players"]
    @other_players = populate_other_players player_hash["other_players"]
    @bet_amount = player_hash["bet"] || 0
    @active = player_hash["active"] || "no"
    @played_games = player_hash["games"] || 0
    @won = player_hash["won"] || 0
  end

  def populate_other_players(hash)
    result = []
    return result if !hash
    #pp "HASH"
    #pp hash
    hash.each do |value|
     result.push( Player.new value ) 
    end
    result
  end

  def add_cards(cards)
    @poker_hand.add_cards(cards)
  end

  def set_action(action)
    @action = action
    if @action == "bet"
      bet 10
    elsif @action == "fold"

    end
    @status = "done"
  end

  def add_table_cards(cards)
    @table_cards.add_cards(cards)
  end

  def clear
    @poker_hand.clear
    @table_cards.clear
    @bet_amount = 0
    @active = "no"
    @status = "wait"
    @action = "none"
  end

  def add_money(money)
    @money += money
  end

  def bet(amount = 10)
    @bet_amount = amount
    @money -= @bet_amount
  end

  def finish_game(state = :lose)
    if state == :win
      @won += 1
    end
    @played_games += 1
    @status = "finished"
  end

  def other_players_json
    @other_players.map(&:to_json)
  end

  def to_json
    JSON.generate({
                    name: @name, 
                    money: @money, 
                    cards: @poker_hand.to_json, 
                    id: @id, 
                    action: @action, 
                    table_cards: @table_cards.to_json,
                    bet: @bet_amount,
                    status: @status,
                    other_players: other_players_json,
                    active: @active,
                    games: @played_games,
                    won: @won
                   })
  end

  def save_to_json
    JSON.generate({
                    name: @name, 
                    money: @money, 
                    id: @id, 
                    games: @played_games,
                    won: @won
                   })
  end


  def best_hand
    return 0 if @action == "fold"
    hand = @table_cards
    hand.add_cards( @poker_hand.cards )
    hand.best_hand
  end

  def card_count
    @poker_hand.size
  end
end
