class ConsoleWindow
  attr_accessor :acted, :selected_action, :player

  def initialize
    @acted = false
    @player = nil
  end

  def player=(value)
    @player = value
    draw
  end

  def show
    #while(true)
    #  if @player && @player.poker_hand && @player.poker_hand.cards.count > 0
    #    break
    #  end
    #end
    loop do
      draw
      while (@player.active == "no")

      end
      draw
      get_input
    end
  end

  def get_input
    input = gets.chomp
    move = check_move(input)
    if move
      @selected_action = move
      @acted = true
    end
  end

  def check_move(move)
    case (move)
    when "1"
      return "check"
    when "2"
      return "bet"
    when "3"
      return "fold"
    else 
      nil
    end
  end

  def draw
    if @player && @player.poker_hand && @player.poker_hand.cards.size > 0
      system "cls"
      puts "Player name: #{@player.name}, money: #{@player.money}"
      if @player.other_players && @player.other_players.count > 0
        @player.other_players.each do |player|
          puts "Opponent #{player.name} has #{player.money} money left"
        end
      end
      
      puts
      puts "Table cards:"
      puts
      draw_cards(@player.table_cards.cards) if @player.table_cards

      puts 
      puts "Your cards:"
      puts 
      draw_cards(@player.poker_hand.cards)
      
      draw_menu
    end
  end

  def draw_menu
    puts
    puts "Possible Moves:"
    puts "1. Check"
    puts "2. Bet 10"
    puts "3. Fold"
  end

  def draw_cards(cards)
    if cards && cards.count > 0
      puts "| #{cards.map(&:to_s).join("|")}|"
    end
  end
end
