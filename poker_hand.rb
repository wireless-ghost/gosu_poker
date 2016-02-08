require "./card.rb"
require "json"

class PokerHand

  include Enumerable

  attr_accessor :cards

  HANDS = {
    #:high_card? => 1,
    :pair? => 2, 
    #:two_pair? => 3,
    :three_of_a_kind? => 4,
    :straight? => 5,
    :flush? => 6,
   # :full_house? => 7,
    :four_of_a_kind? => 8,
    :straight_flush? => 9,
    :royal_flush? => 10
  }

  def initialize(cards)
    @cards = cards
  end

  def each(&block)
    @cards.map do |card|
      yield card
    end
  end

  def size
    @cards.size
  end

  def play_card
    @cards.pop
  end

  def allow_face_up?
    @cards.size <= 3  
  end

  def add_cards(cards)
    cards.each { |card| @cards << card }
  end

  def add_from_json(card_hash)
    pp "pokerHand #{card_hash}"
    card_hash.each do |value|
      val = JSON.parse(value)
      card = Card.new(val["rank"], val["suit"])
      @cards << card
    end
  end

  def clear
    @cards = []
  end

  def check(cards, count)
    p cards
    if (cards.size < count)
      return false
    end
    if (cards[0] + count - 1 == cards[count-1])
      return true
    end
    return check(cards.take(cards.length - 1).to_a, count)
  end

  def draw(x, y)
    @cards.each do |card|
      card.draw(x, y)
      x += 110
    end
  end

  def find_card_by_pos(x, y)
    @cards.each do |card|
      if card.point_in_bounds(x, y)
        return card
      end
    end
    nil
  end

  def high_card?
    @cards.sort{ |a, b| b.value <=> a.value }[0]
  end

  def check_for_same(size)
    @cards.each do |card|
       return true if @cards.select { |other| other.rank == card.rank }.count >= size
    end
    false
  end

  def pair?
   check_for_same(2) 
  end

  def three_of_a_kind?
    check_for_same(3)
  end

  def four_of_a_kind?
    check_for_same(4)
  end
  #{ pair?: 2, three_of_a_kind?: 3, four_of_a_kind?: 4 }.each do |name, target|
  #  define_method("#{name}?") do 
  #    pp target
  #    @cards.select { |card| @cards.count(card) >= target }.size >= target
  #  end
  #end

  def straight?
    pp "straight"
    sort_by_values!
    return true if @cards[0].value - 4 == @cards[4].value
    return true if @cards[1].value - 4 == @cards[5].value
    return true if @cards[2].value - 4 == @cards[6].value
    if @cards.select { |card| card.value == 14 }.count >= 1
      return true if @cards[3].value - 4 == 1
    end
    false
  end

  def flush?
    pp "flush"
    Card::SUITS.each do |suit|
      #pp @cards.select { |card| card.suit == suit }.count
      return true if @cards.select { |card| card.suit == suit }.count > 4
    end
    false
  end

  def straight_flush?
    pp "flush str"
    straight? && flush?
  end

  def royal_flush?
    pp "royal"
    straight? && flush? #&& high_card.rank == :ace
  end

  def sort_by_values!
    @cards.sort!{ |a, b| a.value <=> b.value }.reverse!
  end

  def sort_by_suits!
    @cards.sort!{ |a, b| a.suit <=> b.suit }
  end

  def best_hand
    #pp HANDS.keys
    pp self.send(HANDS.keys.first)
    pp "================"
    hands = HANDS.keys.map { |fun| [fun, self.send(fun)] }
    hands.reverse!
    pp hands
    HANDS[hands.find { |name, result| result == true }.first]
  end

  def to_json
    @cards.map(&:to_json)
    #{cards: cards_json}.to_json
  end
end
