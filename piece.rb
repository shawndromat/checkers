require 'colorize'

class Piece
  
  attr_reader :color, :pos, :board, :kinged
  
  def initialize(pos, color, board, kinged = false)
    @pos, @color, @board = pos, color, board
    @kinged = kinged
    @board.add_piece(self)
  end
  
  def get_sprite
    color == :black ? "\u25c9 ".black : "\u25c9 ".magenta
  end
  
  def inspect
    "pos: #{pos}, color: #{color}"
  end
  
  def perform_moves!(move_sequence)
    if move_sequence.count == 1
      target = move_sequence[0]
      #try sliding first
      if ( perform_slide(target) || perform_jump(target) )
        board.move(self, target) 
      else
        raise InvalidMoveError.new "Can't move there"
      end
    else
      move_sequence.each do |move|
        
      
  end
  
  def perform_slide(target)
    return false unless board[target].nil? && on_board?(target)
    move_diffs = slide_diffs[0...2] unless kinged
    move_diffs.each do |diff|
      return true if [pos.first + diff.first, pos.last + diff.last] == target
    end
    false
  end
  
  def perform_jump(target)
    return false unless board[target].nil? && on_board?(target)
    move_diffs = slide_diffs[0...2] unless kinged
    
    move_diffs.each do |diff|
      opponent = [pos.first + diff.first, pos.last + diff.last]
      jump = [opponent.first + diff.first, opponent.last + diff.last]
      
      next unless jump == target
      #if no opponent square in the short diagonal, can't jump
      return false if board[opponent].nil?
      #if your own piece in the short diagonal, can't jump
      return false unless board[opponent].color != color
      
      #all good, remove opponent and return true
      board[opponent] = nil
      true
      end
    end
    false
  end
  
  def move_diffs
    [
      [ get_direction, 1],
      [ get_direction, -1],
      [ -(get_direction), 1],
      [ -(get_direction), -1]
    ]
  end
  
  def on_board?(pos)
    pos.all? {|coord| (0..7).cover?(coord)}
  end
  
  private
  def get_direction
    color == :black ? 1 : -1
  end
end

class InvalidMoveError < RunTimeError
end