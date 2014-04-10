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
  
  def display(cursor_pos = nil, cursor_start = nil)
    system("clear")
    puts
    @rows.each_with_index do |row, row_idx|
      print " #{row_idx} "
      row.each_with_index do |tile, col_idx|
        sprite = tile.nil?  ? "  " : "#{tile.get_sprite}"
        sprite = sprite.on_cyan if (row_idx + col_idx).odd?
        sprite = sprite.on_yellow if (row_idx + col_idx).even?
        sprite = sprite.on_magenta.blink if [row_idx, col_idx] == cursor_start
        sprite = sprite.on_red.blink if [row_idx, col_idx] == cursor_pos
        print sprite
      end.join("")
      puts
    end
    print "   "
    ('0'..'7').each { |num| print "#{num} "}
    puts
    nil
  end
  
  def dup
    duped_board = Board.new(false)
    pieces.each do |piece|
      duped_board.add_piece(piece.dup(duped_board))
    end
    duped_board
  end
  
  private
  def set_up_pieces
    place_pieces(:black)
    place_pieces(:white)
  end
  
  def place_pieces(color)
    piece_rows = (color == :black ? [0, 1] : [6, 7] )
    self.rows.each_with_index do |row, i|
      next unless piece_rows.include?(i)
      row.each_index do |j|
        Piece.new([i, j], color, self)
      end
    end
  end
  
  def pieces
    @rows.flatten.compact
  end
end