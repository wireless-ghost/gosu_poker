require 'player'
require 'deck'

class Table

  def initialize
    @players = []
    @current_blinds = [0, 0] # small blind, big blind
    @round_counter = 0
    @deck = Deck.new 
    @current_round = 0
    @bids = Hash.new
    @pot = 0
    @table_cards = []
    @active_player = nil
  end

  def play
    @players.each do |player|
      player.play()
    end
  end

  def deal_cards
    @players.each do |player|
      player.add_cards( @deck.deal_cards(2) )
    end
  end
end
