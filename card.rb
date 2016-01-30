require 'gosu'
require 'json'

class Card
  attr_reader :rank, :suit, :x, :y

  ALL_RANKS = [2, 3, 4, 5, 6, 7, 8, 9, :t, :jack, :queen, :king, :ace]
  BELOTE_RANKS = [7, 8, 9, :jack, :queen, :king, 10, :ace]
  SIXTY_SIX_RANKS = [9, :jack, :queen, :king, 10, :ace]

#  SUITS = [:clubs, :diamonds, :hearts, :spades]
  SUITS = [:hearts]

  SUITS_VALUES = { :clubs => 20, :diamonds => 30, :hearts => 40, :spades => 50 }

  def initialize(rank, suit)
    @rank, @suit = rank, suit
    #@image = Gosu::Image.new("assets/#{rank}#{suit.to_s[0].upper}.png")
    @image = Gosu::Image.new("assets/#{rank.to_s[0].upcase}H.png")
  end

  def <=>(other)
    [SUITS.index(other.suit), ALL_RANKS.index(other.rank)] <=> [SUITS.index(@suit), ALL_RANKS.index(@rank)]
  end

  def to_s
    "#{@rank.to_s.capitalize} of #{@suit.to_s.capitalize}"
  end

  def index
    ALL_RANKS.index(@rank) + 2 + SUITS_VALUES[@suit]
  end

  def draw(x, y)
    @x, @y = x, y
    @image.draw(x, y, 1)
  end

  def point_in_bounds(point_x, point_y)
    if point_x > @x && point_x < @x + 100 && point_y > @y && point_y < @y + 150
      true
    else
      false
    end
  end

  def to_json
    {rank: @rank, suit: @suit}.to_json
  end
end