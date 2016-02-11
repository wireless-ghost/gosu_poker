require 'json'
require 'pp'

class Card
  attr_reader :rank, :suit, :x, :y

  ALL_RANKS = [2, 3, 4, 5, 6, 7, 8, 9, "ten", "jack", "queen", "king", "ace"]

  RANK_VALUES = { 
                  2 => 2, 
                  3 => 3, 
                  4 => 4, 
                  5 => 5, 
                  6 => 6, 
                  7 => 7, 
                  8 => 8, 
                  9 => 9, 
                  "ten" => 10, 
                  "jack" => 11,
                  "queen" => 12, 
                  "king" => 13,
                  "ace" => 14
  }

 # SUITS = ["clubs", "diamonds", "hearts", "spades"]
  SUITS = ["hearts"]

  SUITS_VALUES = { :clubs => 20, :diamonds => 30, :hearts => 40, :spades => 50 }

  def initialize(rank, suit)
    @rank, @suit = rank, suit
  end

  def <=>(other)
    [SUITS.index(other.suit), ALL_RANKS.index(other.rank)] <=> [SUITS.index(@suit), ALL_RANKS.index(@rank)]
  end

  def to_s
    "#{@rank.to_s[0].capitalize}#{@suit.to_s[0].capitalize}"
  end

  def index
    ALL_RANKS.index(@rank) + 2 + SUITS_VALUES[@suit]
  end

  def value
    RANK_VALUES[@rank]
  end

  def to_json
    {rank: @rank, suit: @suit}.to_json
  end
end
