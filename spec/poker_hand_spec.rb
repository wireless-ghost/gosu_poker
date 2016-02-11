require 'spec_helper'

describe 'Task' do
    describe PokerHand do
      it 'can find high_card' do
        cards = []
        cards << Card.new("jack", "hearts")
        cards << Card.new("jack", "spades")
        hand = PokerHand.new(cards)
        expect(hand.high_card?).to eq 11
      end

      it 'can find pair' do
        cards = []
        cards << Card.new("jack", "hearts")
        cards << Card.new("jack", "spades")
        hand = PokerHand.new(cards)
        expect(hand.pair?).to eq true
      end

      it 'can find 3 of a kind' do
        cards = []
        cards << Card.new("jack", "hearts")
        cards << Card.new("jack", "spades")
        cards << Card.new("jack", "diamonds")
        hand = PokerHand.new(cards)
        expect(hand.three_of_a_kind?).to eq true
      end

      it 'can find 4 of a kind' do
        cards = []
        cards << Card.new("jack", "hearts")
        cards << Card.new("jack", "spades")
        cards << Card.new("jack", "diamonds")
        cards << Card.new("jack", "clubs")
        hand = PokerHand.new(cards)
        expect(hand.four_of_a_kind?).to eq true
      end

      it 'can find straight' do
        cards = []
        cards << Card.new("queen", "hearts")
        cards << Card.new("jack", "spades")
        cards << Card.new("ten", "diamonds")
        cards << Card.new("ace", "clubs")
        cards << Card.new("king", "clubs")
        cards << Card.new(8, "hearts")
        cards << Card.new(2, "clubs")

        hand = PokerHand.new(cards)
        expect(hand.straight?).to eq true
      end

      it 'can find flush' do
        cards = []
        cards << Card.new(5, "hearts")
        cards << Card.new("jack", "hearts")
        cards << Card.new("ten", "hearts")
        cards << Card.new("ace", "hearts")
        cards << Card.new("king", "clubs")
        cards << Card.new(8, "hearts")
        cards << Card.new(2, "clubs")

        hand = PokerHand.new(cards)
        expect(hand.flush?).to eq true
      end

      it 'can find straight flush' do
        cards = []
        cards << Card.new("queen", "hearts")
        cards << Card.new("jack", "hearts")
        cards << Card.new("ten", "hearts")
        cards << Card.new("ace", "hearts")
        cards << Card.new("king", "hearts")
        cards << Card.new(8, "spades")
        cards << Card.new(2, "clubs")

        hand = PokerHand.new(cards)
        expect(hand.straight_flush?).to eq true
      end

      it 'can find royal flush' do
        cards = []
        cards << Card.new("queen", "hearts")
        cards << Card.new("jack", "hearts")
        cards << Card.new("ten", "hearts")
        cards << Card.new("ace", "hearts")
        cards << Card.new("king", "hearts")
        cards << Card.new(8, "spades")
        cards << Card.new(2, "clubs")

        hand = PokerHand.new(cards)
        expect(hand.royal_flush?).to eq true
      end

      it 'returns correct value' do
        expect(Card.new(2, "spades").value).to eq 2
      end

      it 'can clear' do
        cards = []
        cards << Card.new("jack", "hearts")
        cards << Card.new("jack", "spades")
        hand = PokerHand.new(cards)
        hand.clear

        expect(hand.cards).to eq []
      end


      it 'can calculate size' do
        cards = []
        cards << Card.new("jack", "hearts")
        cards << Card.new("jack", "spades")
        hand = PokerHand.new(cards)
        expect(hand.size).to eq 2
      end


    end
end
