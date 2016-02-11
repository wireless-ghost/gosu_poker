require 'spec_helper'

describe 'task' do
    describe Card do
      it 'can convert card to string' do
        card = Card.new("jack", "hearts")
        expect(card.to_s).to eq "JH"
      end

      it 'returns correct value' do
        expect(Card.new(2, "spades").value).to eq 2
      end
    end
end
