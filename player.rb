require 'json'
require "./poker_hand.rb"
require 'securerandom'
require 'pp'

class Player
  attr_reader :name, :money, :id, :poker_hand, :table_cards
  attr_accessor :action, :status, :other_players, :active

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
    pp player_hash["other_players"]
    @other_players = populate_other_players player_hash["other_players"]
    @bet = player_hash["bet"] || 0
    @active = player_hash["active"] || "no"
  end

  def populate_other_players(hash)
    result = []
    return result if !hash
    pp "HASH"
    pp hash
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
    @status = "done"
  end

  def add_table_cards(cards)
    @table_cards.add_cards(cards)
  end

  def clear
    @poker_hand.clear
    @table_cards.clear
    @bet = 0
    @active = "no"
    @status = "wait"
  end

  #def clear_hand
  #  poker_hand.clear
  #end

  def add_money(money)
    @money += money
  end

  def bet(amount)
    @money -= amount
    amount
  end

  def play
    
  end

  def other_players_json
    @other_players.map(&:to_json)
  end

  def to_json
    #pp "OTHEEEEEEEER TO JSON INT #{@name}"
    #pp @other_players
    JSON.generate({
                    name: @name, 
                    money: @money, 
                    cards: @poker_hand.to_json, 
                    id: @id, 
                    action: @action, 
                    table_cards: @table_cards.to_json,
                    bet: @bet,
                    status: @status,
                    other_players: other_players_json,
                    active: @active
                   })
  end

  def best_hand
    #pp "PLAYER BEST_HAND"
    @table_cards.add_cards( @poker_hand.cards )
    #pp "DOBAVENI"
    #pp @table_cards
    @table_cards.best_hand
  end

  def card_count
    @poker_hand.size
  end
end
