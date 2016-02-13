require "./card.rb"
require "json"
require 'deep_clone'

class PokerHand
  include Enumerable

  attr_accessor :cards

  HANDS = {
    :high_card? => 1,
    :pair? => 20, 
    :two_pair? => 30,
    :three_of_a_kind? => 40,
    :straight? => 50,
    :flush? => 60,
    :full_house? => 7,
    :four_of_a_kind? => 80,
    :straight_flush? => 90,
    :royal_flush? => 100
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

  def add_cards(cards)
    cards.each { |card| @cards << card }
  end

  def add_from_json(card_hash)
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
    if (cards.size < count)
      return false
    end
    if (cards[0] + count - 1 == cards[count-1])
      return true
    end
    return check(cards.take(cards.length - 1).to_a, count)
  end

  def high_card?
    sorted = @cards.sort{ |a, b| b.value <=> a.value }
    sorted.first.value
  end

  def check_for_same(size, cards = @cards)
    cards.each do |card|
      return true if cards.select { |other| other.rank == card.rank }.count >= size
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

  def full_house?
    cards = DeepClone.clone @cards
    two = get_duplicated cards, 2
    return false if !two
    two.each do |used|
      cards.delete used
    end
    three = get_duplicated cards, 3
    return false if !three
    true
  end

  def two_pair?
    cards = DeepClone.clone @cards
    first_double = get_duplicated cards, 2
    return false if !first_double
    first_double.each do |used|
      cards.delete used
    end
    second_double = get_duplicated cards, 3
    return false if !second_double
    true
  end

  def get_duplicated(cards, count)
    return nil if !check_for_same(count, cards)
    result = []
    cards.each do |card|
      cards.each do |other|
        if card != other && card.rank == other.rank && !(result.include?(other))
          result.push(other)
          break if result.size == count
        end
      end
    end
    result
  end

  def straight?
    sort_by_values!
    return true if @cards[0].value - 4 == @cards[4].value
    return true if @cards[1].value - 4 == @cards[5].value
    return true if @cards[2].value - 4 == @cards[6].value
    if @cards.select { |card| card.value == 14 }.count >= 1
      return true if @cards[3].value - 4 == 1
    end
    false
  end

  def sum_result(first, second)
    @cards[first..second].map(&:value).inject(:+)
  end

  def straight
    sort_by_values!
    if @cards[0].value - 4 == @cards[4].value
      return sum_result(0, 4)
    elsif @cards[1].value - 4 == @cards[5].value
      return sum_result(1, 5)
    elsif @cards[2].value - 4 == @cards[6].value
      return sum_result(2, 6)
    elsif @cards.select { |card| card.value == 14 }.count >= 1
      if @cards[3].value - 4 == 1
        return 15 # sum from 1 to 5
      end
    end
    0
  end

  def flush?
    Card::SUITS.each do |suit|
      return true if @cards.select { |card| card.suit == suit }.count > 4
    end
    false
  end

  def straight_flush?
    straight? && flush?
  end

  def royal_flush?
    straight? && flush? && high_card? == 14
  end

  def sort_by_values!
    @cards.sort!{ |a, b| a.value <=> b.value }.reverse!
  end

  def sort_by_suits!
    @cards.sort!{ |a, b| a.suit <=> b.suit }
  end

  def best_hand
    hands = HANDS.keys.map { |fun| [fun, self.send(fun)] }
    hands.reverse!
    winner = hands.find { |name, result| result }
    if (winner.first == :high_card?)
      return winner.last
    end
    HANDS[hands.find { |name, result| result }.first]
  end

  def to_json
    @cards.map(&:to_json)
  end
end
