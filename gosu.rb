require 'gosu'
require './deck.rb'
require './card.rb'
require './poker_hand.rb'

module ZOrder
  Background, Card, UI = *0..2
end

class Button
  attr_accessor :x, :y, :name

  def initialize(button_name)
    @x, @y = 0, 0
    @name = button_name
    @image = Gosu::Image.new("assets/buttons/#{button_name}_button.png")
  end

  def point_in_bounds?(point_x, point_y)
    if point_x >= @x && point_x <= @x + 100 && point_y >= @y && point_y <= @y + 50
      true
    else
      false
    end
  end

  def draw(x, y)
    @x, @y = x, y
    @image.draw(x, y, 1)
  end
end

class GameWindow < Gosu::Window
  attr_accessor :acted, :selected_action, :player

  def initialize
    super 692, 365
    self.caption = 'NA NA NA BATMAN'
    @background = Gosu::Image.new('assets/table.png')
    @font = Gosu::Font.new(20)
    @font2 = Gosu::Font.new(20)
    @fontMessage = Gosu::Font.new(20)
    @raise = Button.new('raise')
    @fold = Button.new('fold')
    @check = Button.new('check')
    @bet = Button.new('bet')
    @acted = false
    @cards = {}
    @player = nil
  end

  def update
    if @player
      load_cards(@player.table_cards.cards) if @player.table_cards
      load_cards(@player.poker_hand.cards) if @player.poker_hand
    end
  end

  def load_cards(cards)
    cards.each do |card|
      if !@cards.has_key?(card.to_s)
        @cards[card.to_s] = Gosu::Image.new("assets/#{card.suit.to_s}/#{card.to_s}.png")
      end
    end
  end

  def draw_table_cards(x, y, cards)
    cards.each do |card|
      @cards[card.to_s].draw(x, y, 1)
      x += 110
    end
  end

  def draw
    @background.draw(0,0, ZOrder::Background)
    if @player && @player.poker_hand && @player.poker_hand.size > 0
      @check.draw(435, 260)
      @fold.draw(550, 260)
      @bet.draw(435, 315)

      draw_table_cards(80, 100, @player.table_cards.cards) if @player.table_cards
      draw_table_cards(220, 260, @player.poker_hand.cards) if @player.poker_hand
      if @player.other_players.count > 0
        @font2.draw("Player: #{@player.other_players.first.name} IS PLAYING WITH YOU", 10, 25, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
      end
      if @player.active == "no"
        @fontMessage.draw("Waiting for others to play.", 250, 80, ZOrder::UI, 1.0, 1.0, 0xff_ffffff)
      end
      @font.draw("Player: #{@player.name}, money: #{@player.money}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    end
  end

  def button_down(id)
    case id 
    when Gosu::KbEscape
      close
      exit
    when Gosu::MsLeft
      if @player.active == "yes"
        x, y = mouse_x, y = mouse_y
        puts "Mouse x: #{x}, y: #{y}"
        button = find_selected_button(x, y)
        puts button if button
        @selected_action = button
        @acted = true
      end
    end
  end

  def needs_cursor?
    true
  end

  def find_selected_button(x, y)
    button = nil
    if @raise.point_in_bounds?(x, y)
      button = @raise.name
    elsif @bet.point_in_bounds?(x, y)
      button = @bet.name
    elsif @check.point_in_bounds?(x, y)
      button = @check.name
    elsif @fold.point_in_bounds?(x, y)
      button = @fold.name
    end
  end
end
