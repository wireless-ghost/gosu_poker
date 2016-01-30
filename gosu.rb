require 'gosu'
require './deck.rb'
require './card.rb'
require './poker_hand.rb'

module ZOrder
  Background, Card, Stars, Player, UI = *0..4
end

class Button
  attr_accessor :x, :y, :name

  def initialize(button_name)
    @x, @y = 0, 0
    @name = button_name
    @image = Gosu::Image.new("assets/#{button}_button.png")
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
  attr_accessor :poker_hand, :acted, :selected_action, :player_hand, :player

  def initialize
    super 692, 365
    self.caption = 'NA NA NA BATMAN'
    #@player_hand = nil
    #@poker_hand = nil
    @background = Gosu::Image.new('assets/table.png')
    @font = Gosu::Font.new(20)
    @raise = Button.new('button')
    @fold = Button.new('button')
    @check = Button.new('button')
    @bet = Button.new('button')
    @acted = false
  end

  def update
    if Gosu::button_down? Gosu::KbLeft or Gosu::button_down? Gosu::GpLeft then
      #@player.turn_left
    end
    if Gosu::button_down? Gosu::KbRight or Gosu::button_down? Gosu::GpRight then
      #@player.turn_right
    end
    if Gosu::button_down? Gosu::KbUp or Gosu::button_down? Gosu::GpButton0 then
      #@player.accelerate
    end
  end

  def draw
    @background.draw(0,0, ZOrder::Background)
    if (@player && @player.poker_hand && @player.poker_hand.size > 0)
      @check.draw(435, 260)
      @fold.draw(550, 260)
      @bet.draw(435, 315)
      @raise.draw(550, 315)
      @player.table_cards.draw(100, 100) if @player.table_cards
      @player.poker_hand.draw(220, 260)
      @font.draw("Player: #{@player.name}, money: #{@player.money}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff_ffff00)
    end
  end

  def button_down(id)
    case id 
    when Gosu::KbEscape
      close
      exit
    when Gosu::MsLeft
      x, y = mouse_x, y = mouse_y
      puts "Mouse x: #{x}, y: #{y}"
      button = find_selected_button(x, y)
      puts button if button
      @selected_action = button
      @acted = true
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

  def find_selected_card(x, y)
    card = @poker_hand.find_card_by_pos(x, y)
    #if !card
     # card = @player_hand.find_card_by_pos(x, y)
    #end
    if card
      card.to_s
    else
      nil
    end
  end
end

#window = GameWindow.new
#window.show
