require_relative 'spec_helper'
require_relative '../lib/game'
require_relative '../lib/opening'
require_relative '../lib/endgame_position'

RSpec.describe Game do
  let(:game) do
    Game.create(
      pgn_notation: '1. e4 e5 2. Nf3 Nc6',
      final_fen: 'rnbqkbnr/pppp1ppp/4p3/8/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3',
      result: 'white_wins',
      white_pieces_count: 16,
      black_pieces_count: 15
    )
  end

  describe '#is_endgame?' do
    context 'when white has less than 7 pieces' do
      it 'returns true' do
        game.white_pieces_count = 6
        expect(game.is_endgame?).to be true
      end
    end

    context 'when black has less than 7 pieces' do
      it 'returns true' do
        game.black_pieces_count = 6
        expect(game.is_endgame?).to be true
      end
    end

    context 'when both sides have 7 or more pieces' do
      it 'returns false' do
        game.white_pieces_count = 8
        game.black_pieces_count = 8
        expect(game.is_endgame?).to be false
      end
    end
  end

  describe '#result_score_for_white' do
    it 'returns 1.0 for white wins' do
      game.result = 'white_wins'
      expect(game.result_score_for_white).to eq(1.0)
    end

    it 'returns 0.0 for black wins' do
      game.result = 'black_wins'
      expect(game.result_score_for_white).to eq(0.0)
    end

    it 'returns 0.5 for draws' do
      game.result = 'draw'
      expect(game.result_score_for_white).to eq(0.5)
    end
  end

  describe '#result_score_for_black' do
    it 'returns 0.0 for white wins' do
      game.result = 'white_wins'
      expect(game.result_score_for_black).to eq(0.0)
    end

    it 'returns 1.0 for black wins' do
      game.result = 'black_wins'
      expect(game.result_score_for_black).to eq(1.0)
    end

    it 'returns 0.5 for draws' do
      game.result = 'draw'
      expect(game.result_score_for_black).to eq(0.5)
    end
  end
end
