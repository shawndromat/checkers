require './piece.rb'
require 'colorize'

class Board
  
  attr_accessor :rows
  
  def initialize(start_board = true)
    @rows  = Array.new(8) { Array.new(8) }
    set_up_pieces if start_board
  end
  
  def add_piece(piece)
    self[piece.pos] = piece
  end
  
  def [](pos)
    x, y = pos
    @rows[x][y]
  end

  def []=(pos, piece)
    x, y = pos
    @rows[x][y] = piece
  end
  
  def move(start_pos, end_pos)
    current_piece = self[start_pos]
    current_piece.pos = end_pos
    self.add_piece(current_piece)
    self[start_pos] = nil
  end
  
  def display(cursor_pos = nil, selected = [])
    "".tap do |display_string|
      @rows.each_with_index do |row, i|
        display_string << " #{i} "
        row.each_with_index do |tile, j|
          sprite = tile.nil? ? "  " : tile.to_s 
          if [i, j] == cursor_pos 
            display_string << sprite.on_red.blink 
          elsif selected.include?([i, j])
            display_string << sprite.on_green
          else
            display_string << sprite.on_cyan if (i + j).odd?
            display_string << sprite.on_yellow if (i + j).even?
          end
        end
        display_string << "\n"
      end
      display_string << "   "
      ('0'..'7').each { |num| display_string << "#{num} "}
      # display_string << "\n"
    end
  end
  
  def dup
    duped_board = Board.new(false)
    pieces.each do |piece|
      duped_board.add_piece(piece.dup(duped_board))
    end
    duped_board
  end
  
  def pieces
    @rows.flatten.compact
  end
  
  private
  def set_up_pieces
    place_pieces(:black)
    place_pieces(:white)
  end
  
  def place_pieces(color)
    piece_rows = (color == :black ? [0, 1, 2] : [5, 6, 7] )
    self.rows.each_with_index do |row, i|
      next unless piece_rows.include?(i)        
        row.each_index do |j|
          next if (i + j).even?
          Piece.new([i, j], color, self)
        end
    end
  end
end