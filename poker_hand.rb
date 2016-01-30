require "./card.rb"
require "json"

class PokerHand

  include Enumerable

  attr_accessor :cards

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

  def highest_of_suit(suit)
    if (@cards.any? { |card| card.suit == suit} )
      @cards.select { |card| card.suit == suit }.sort_by { |card| Card::BELOTE_RANKS.index(card.rank) }.first
    end
  end

  def belote?
    kings = @cards.select { |card| card.rank == Card::BELOTE_RANKS.index(:king) }
    queens = @cards.select { |card| card.rank == Card::BELOTE_RANKS.index(:queen) }

    kings.any? { |king| queens.any? { |queen| Card::BELOTE_RANKS.index(king_card.suit) == Card::BELOTE_RANKS.index(queen_card.suit) } }
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
  
  def tierce?()
    cards = @cards.dup
    check(cards.sort.reverse.map(&:index).to_a, 3)
  end

  def quarte?()
    cards = @cards.dup
    check(cards.sort.reverse.map(&:index).to_a, 4)
  end

  def quint?()
    cards = @cards.dup
    check(cards.sort.reverse.map(&:index).to_a, 5)
  end

  def four_of_a_kind?(rank)
    fours = @cards.select { |card| Card::BELOTE_RANKS.index(card.rank) == Card::BELOTE_RANKS.index(rank) }
    fours != nil ? fours.size == 4 : false
  end

  def carre_of_jacks?()
    four_of_a_kind?(:jack)
  end

  def carre_of_nines?()
    four_of_a_kind?(9)
  end

  def carre_of_aces?()
    four_of_a_kind?(:ace)
  end

  def twenty?(trump_suit)
    not_trump = @cards.select { |card| Card::SUITS.index(card.suit) != Card::SUITS.index(trump_suit) }
    kings = not_trump.select { |card| Card::SIXTY_SIX_RANKS.index(card.rank) == Card::SIXTY_SIX_RANKS.index(:king)}
    quieens = not_trump.select { |card| Card::SIXTY_SIX_RANKS.index(card.rank) == Card::SIXTY_SIX_RANKS.index(:queen)}

    kings.any? { |king| queens.any? { |queen| Card::SIXTY_SIX_RANKS.index(queen.suit) == Card::SIXTY_SIX_RANKS.index(king.suit) } }
  end

  def forty?(trump_suit)
    not_trump = @cards.select { |card| Card::SUITS.index(card.suit) == Card::SUITS.index(trump_suit) }
    kings = not_trump.select { |card| Card::SIXTY_SIX_RANKS.index(card.rank) == Card::SIXTY_SIX_RANKS.index(:king)}
    quieens = not_trump.select { |card| Card::SIXTY_SIX_RANKS.index(card.rank) == Card::SIXTY_SIX_RANKS.index(:queen)}

    kings.any? { |king| queens.any? { |queen| Card::SIXTY_SIX_RANKS.index(queen.suit) == Card::SIXTY_SIX_RANKS.index(king.suit) } }
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

  def to_json
    @cards.map(&:to_json)
    #{cards: cards_json}.to_json
  end
end
