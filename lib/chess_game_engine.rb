require 'chess'

class ChessGameEngine
  attr_reader :game, :moves_history, :pgn_moves

  def initialize
    @game = Chess::Game.new
    @moves_history = []
    @pgn_moves = []
  end

  def make_move(from, to, promotion = nil)
    move_notation = build_move_notation(from, to, promotion)
    move_str = from + to
    move_str += promotion.to_s.downcase if promotion
    begin
      @game.move(move_str)
      @moves_history << { from: from, to: to, promotion: promotion }
      @pgn_moves << move_notation
      { success: true, notation: move_notation }
    rescue StandardError => e
      { success: false, error: e.message }
    end
  end

  def current_fen
    @game.board.to_fen
  end

  def current_pgn
    @pgn_moves.join(' ')
  end

  def game_over?
    @game.board.checkmate? || stalemate? || insufficient_material?
  end

  def checkmate?
    @game.board.checkmate?
  end

  def stalemate?
    @game.board.stalemate?
  end

  def insufficient_material?
    @game.board.insufficient_material?
  end

  def winner
    return nil unless checkmate?

    @game.turn == :white ? 'black' : 'white'
  end

  def first_ten_moves
    @pgn_moves.first(10).join(' ')
  end

  def first_move_by_white
    @pgn_moves.first
  end

  def piece_count(color)
    fen_parts = current_fen.split(' ')
    board_state = fen_parts[0]

    pieces = color == 'white' ? 'PRNBQK' : 'prnbqk'
    count = 0

    board_state.each_char do |char|
      count += 1 if pieces.include?(char)
    end

    count
  end

  def white_pieces_count
    piece_count('white')
  end

  def black_pieces_count
    piece_count('black')
  end

  def is_endgame?
    white_pieces_count < 7 || black_pieces_count < 7
  end

  def valid_moves_from(square)
    @game.moves(from: square).map { |move| move[:to] }
  rescue StandardError
    []
  end

  def board_state
    @game.board.to_s
  end

  private

  def build_move_notation(from, to, promotion = nil)
    # This is a simplified notation builder
    # In a full implementation, you'd want proper algebraic notation
    notation = "#{from}#{to}"
    notation += "=#{promotion.upcase}" if promotion
    notation
  end
end
