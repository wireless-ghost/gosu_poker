require './card.rb'
require './poker_hand.rb'

class Deck
  include Enumerable

  alias_method :top_card, :first

  def initialize(cards = nil)
    @cards = (cards || generate_all_cards)
  end

  def each(&block)
    @cards.map do |card|
      yield card
    end
  end

  def size
    @cards.size
  end

  def shuffle
    @cards = @cards.shuffle
  end

  def sort
    @cards.sort
  end

  def to_s
    @cards.map(&:to_s).join("\n")
  end

  def deal(number = 1)
    PokerHand.new(@cards.pop(number))
  end

  private

  def generate_all_cards
    Card::ALL_RANKS.product(Card::SUITS).map { |card| Card.new(*card) }.shuffle
  end
end
