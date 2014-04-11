require 'colorize'
require 'yaml'
require 'io/console'
require './player.rb'
require './board.rb'

class Game
  attr_reader :board
  attr_accessor :cursor
  
  def initialize
    @board = Board.new
  end

  def set_players
    system("clear")
    puts "Enter first player's name:"
    name = gets.chomp
    @current_player = Player.new(:white, name)
    puts "Enter second player's name:"
    name = gets.chomp
    @opposite_player = Player.new(:black, name)
  end

  def play
    set_players
    @cursor = [7,0]

    until over?
      player_move
      @current_player, @opposite_player = @opposite_player, @current_player
    end

    puts board.display
    
    puts "#{@opposite_player.name} wins and #{@current_player.name} loses!"
  end
  
  def over?
    black_pieces = board.pieces.select{ |piece| piece.color == :black}
    white_pieces = board.pieces.select{|piece| piece.color == :white}
    black_pieces.count == 0 || white_pieces.count == 0
  end
  
  def player_move
    @error_message = ""
    
    begin
      @moves = []
      get_moves
      piece_pos = @moves.shift
      board[piece_pos].perform_moves(@moves)
    rescue InvalidMoveError => e
      @error_message = e.message
      retry
    end
  end
  
  def get_moves
    listening = true
    while listening
      system("clear")
      puts
      puts "Use 'w', 'a', 's' and 'd' to move".green
      puts "Press <space> to select your moves and 'g' to go".green
      puts "You can quit at any time by pressing 'q'".green
      puts board.display(@cursor, @moves)
      puts "#{@current_player.name}'s turn."
      puts @error_message

      listening = get_user_input
    end
  end
  
  def get_user_input
    begin
      key = $stdin.getch
      first, last = @cursor
      case key
      when 'w'
        @cursor = [first - 1, last] unless first == 0
      when 's'
        @cursor = [first + 1, last] unless first == 7
      when 'a'
        @cursor = [first, last - 1] unless last == 0
      when 'd'
        @cursor = [first, last + 1] unless last == 7
      when ' '
        select_piece
      when 'g'
        select_piece
        return false
      when 'q'
        exit
      else
        raise WrongKeyError.new
      end
    rescue WrongKeyError
      retry
    end
    key
  end
  
  def select_piece
    if @moves.count == 0
      if board[cursor].nil?
        raise InvalidMoveError.new "There's no piece there"
      elsif board[cursor].color != @current_player.color
        raise InvalidMoveError.new "That's not your piece"
      else
        @moves << cursor
      end
    else
      @moves << cursor unless @moves.include?(@cursor)
    end
  end
end

class WrongKeyError < StandardError
end

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.play
end