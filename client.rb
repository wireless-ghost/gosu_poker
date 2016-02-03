require 'socket'
require './player.rb'
require 'json'
require './gosu.rb'
require 'pp'

class Client
  def initialize(server)
    @server = server
    @request = nil
    @response = nil
    @player = nil
    @window = GameWindow.new
    Thread.new do
      @window.show
    end
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
        @window.player = @player
        #@window.poker_hand = @player.table_cards
      }
    end
  end

  def send
    puts "Enter the username:"
    msg = gets.chomp
    @player = Player.new({name:msg, money:300}.to_json)
    @server.puts @player.to_json
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
      }
    end
  end
end

server = TCPSocket.open("localhost", 2000)
Client.new(server)
