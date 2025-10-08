require_relative 'spec_helper'
require_relative '../lib/chess_game_engine'

RSpec.describe ChessGameEngine do
  let(:engine) { ChessGameEngine.new }

  describe '#initialize' do
    it 'creates a new chess game' do
      expect(engine.game).to be_a(Chess::Game)
    end

    it 'initializes empty moves history' do
      expect(engine.moves_history).to be_empty
    end

    it 'initializes empty PGN moves' do
      expect(engine.pgn_moves).to be_empty
    end
  end

  describe '#make_move' do
    context 'with valid move' do
      it 'makes the move and returns success' do
        result = engine.make_move('e2', 'e4')

        expect(result[:success]).to be true
        expect(result[:notation]).to eq('e2e4')
        expect(engine.moves_history.length).to eq(1)
        expect(engine.pgn_moves).to include('e2e4')
      end
    end

    context 'with invalid move' do
      it "returns error and doesn't update history" do
        result = engine.make_move('e2', 'e5')

        expect(result[:success]).to be false
        expect(result[:error]).to be_a(String)
        expect(engine.moves_history).to be_empty
        expect(engine.pgn_moves).to be_empty
      end
    end
  end

  describe '#game_over?' do
    it 'returns false for new game' do
      expect(engine.game_over?).to be false
    end
  end

  describe '#piece_count' do
    it 'counts white pieces correctly at start' do
      expect(engine.white_pieces_count).to eq(16)
    end

    it 'counts black pieces correctly at start' do
      expect(engine.black_pieces_count).to eq(16)
    end
  end

  describe '#is_endgame?' do
    it 'returns false at game start' do
      expect(engine.is_endgame?).to be false
    end
  end

  describe '#first_move_by_white' do
    it 'returns nil when no moves made' do
      expect(engine.first_move_by_white).to be_nil
    end

    it 'returns first move after making it' do
      engine.make_move('e2', 'e4')
      expect(engine.first_move_by_white).to eq('e2e4')
    end
  end

  describe '#current_fen' do
    it 'returns starting position FEN' do
      expect(engine.current_fen).to include('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR')
    end
  end
end
