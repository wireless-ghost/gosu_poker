require 'socket'
require './player.rb'
require 'json'
require './gosu.rb'
require './console_client.rb'
require 'pp'

class Client
  def initialize(server)
    @server = server
    @request = nil
    @response = nil
    @player = nil
    @window = GameWindow.new
    #@window = ConsoleWindow.new
    listen
    send
    @request.join
    @response.join
  end

  def listen
    @response = Thread.new do
      loop {
        msg = @server.gets.chomp
        #pp "CLIENT GOT #{msg}"
        @player = Player.new(msg)
        #pp "PLAYER GOT "
        #pp @player
        @window.player = @player
        if @player.status == "finished"
          File.open("./#{@player.name}.txt", 'w+') do |file|
            file.puts @player.save_to_json
          end
         # pp "SAVED"
        end
        #@window.poker_hand = @player.table_cards
      }
    end
  end

  def send
    while(true) do 
      puts "Please, select an option:"
      puts "1. Enter username"
      puts "2. Load existing user"
      puts "Select: "
      msg = gets.chomp
      if msg == "1"
        puts "Please, enter your username: "
        msg = gets.chomp
        @player = Player.new({name: msg, money: 300}.to_json)
        break
      elsif msg == "2"
        puts "Please, enter the name of the file (we assume it is in the current directory) :"
        msg = gets.chomp
        if File.exist?("./#{msg}.txt")
          File.open("./#{msg}.txt", "r") do |file|
            msg = file.gets.chomp
            @player = Player.new(msg)
          end
        else
          puts "There is no such file! Please, try again!"
        end
        break
      end
    end

    #@player = Player.new({name:msg, money:300}.to_json)
    @server.puts @player.to_json
    
    @window.player = @player

    Thread.new do
      @window.show
    end


    @request = Thread.new do
      loop {
        @window.acted = false
        while(!@window.acted) do
        end
        #pp @player
        @player.set_action(@window.selected_action)
        #if @player
        #pp @player.action
        @server.puts @player.to_json
        #end
        #pp "prateno"
      }
    end
  end
end

server = TCPSocket.open("localhost", 2000)
Client.new(server)
