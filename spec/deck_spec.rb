require 'spec_helper'

describe 'Deck' do 
  describe Deck do 
   it "has correct size" do
     deck = Deck.new

     expect(deck.size).to eq 52
   end

   it "deals 1 card" do
     deck = Deck.new
     deck.deal
     expect(deck.size).to eq 51
   end

   it "deals 3 cards" do
     deck = Deck.new
     deck.deal(3)

     expect(deck.size).to eq 49
   end
  end
end
