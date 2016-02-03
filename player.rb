require 'json'
require "./poker_hand.rb"
require 'securerandom'
require 'pp'

class Player
  attr_reader :name, :money, :id, :poker_hand, :table_cards
  attr_accessor :action, :status

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
  end

  def add_cards(cards)
    @poker_hand.add_cards(cards)
  end

  def set_action(action)
    @action = action
  end

  def add_table_cards(cards)
    @table_cards.add_cards(cards)
  end

  def clear
    @poker_hand.clear
    @table_cards.clear
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

  def to_json
    JSON.generate({name: @name, 
                   money: @money, 
                   cards: @poker_hand.to_json, 
                   id: @id, 
                   action: @action, 
                   table_cards: @table_cards.to_json})
  end

  def card_count
    @poker_hand.size
  end
end
