require 'colorize'
require 'debugger'

class Piece
  attr_reader :color, :board
  attr_accessor :pos, :kinged
  
  def initialize(pos, color, board, kinged = false)
    @pos, @color, @board = pos, color, board
    @kinged = kinged
    @board.add_piece(self)
  end
  
  def to_s
    if kinged
      color == :black ? "\u265A ".black : "\u265A ".magenta
    else
      color == :black ? "\u25c9 ".black : "\u25c9 ".magenta
    end
  end
  
  def inspect
    "pos: #{pos}, color: #{color}"
  end
  
  def dup(duped_board)
    Piece.new(pos, color, duped_board, kinged)
  end
  
  def perform_moves(move_sequence)
    if valid_move_seq?(move_sequence)
      perform_moves!(move_sequence)
    else
      raise InvalidMoveError.new "Invalid move, try again"
    end
  end
  
  protected
  def valid_move_seq?(move_sequence)
    if move_sequence.count == 0
      raise InvalidMoveError.new "Move can't be empty" 
    end
    
    duped_board = board.dup
    duped_piece = self.dup(duped_board)
    begin
      duped_piece.perform_moves!(move_sequence)
    rescue InvalidMoveError
      return false
    end
    true
  end
  
  def perform_moves!(move_sequence)
    if move_sequence.count == 1
      target = move_sequence[0]
      #if only one move try sliding first, then try a single jump
      if perform_slide(target) || perform_jump(target)
        board.move(pos, target)
      else
        raise InvalidMoveError.new "Can't move there"
      end
    else
      #multiple moves must be all jumps
      move_sequence.each do |target|
        if perform_jump(target)
          board.move(pos,target)
        else
          raise InvalidMoveError.new "One of those jumps is illegal"
        end
      end
    end
    maybe_promote
  end
  
  private
  def get_direction
    color == :black ? 1 : -1
  end
  
  def perform_slide(target)
    return false unless board[target].nil? && on_board?(target)

    move_diffs.each do |diff|
      return true if [pos.first + diff.first, pos.last + diff.last] == target
    end
    false
  end
  
  def perform_jump(target)
    return false unless board[target].nil? && on_board?(target)
        
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
      return true
    end
    false
  end
  
  def move_diffs
    diffs = [
      [ get_direction, 1],
      [ get_direction, -1],
      [ -(get_direction), 1],
      [ -(get_direction), -1]
    ]
    self.kinged ? diffs : diffs[0...2]
  end
  
  def on_board?(pos)
    pos.all? {|coord| (0..7).cover?(coord)}
  end
  
  def maybe_promote
    return true if kinged
    self.kinged = (color == :black ? pos.first == 7 : pos.first == 0)
  end
end

class InvalidMoveError < StandardError
end