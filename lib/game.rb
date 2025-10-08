require 'sequel'

class Game < Sequel::Model
  one_to_many :game_openings
  one_to_many :game_endgame_positions
  many_to_many :openings, left_key: :game_id, right_key: :opening_id, join_table: :game_openings
  many_to_many :endgame_positions, left_key: :game_id, right_key: :endgame_position_id,
                                   join_table: :game_endgame_positions

  def before_create
    self.created_at = DateTime.now
    self.updated_at = DateTime.now
    super
  end

  def before_update
    self.updated_at = DateTime.now
    super
  end

  def is_endgame?
    white_pieces_count < 7 || black_pieces_count < 7
  end

  def result_score_for_white
    case result
    when 'white_wins'
      1.0
    when 'black_wins'
      0.0
    when 'draw'
      0.5
    else
      0.0
    end
  end

  def result_score_for_black
    1.0 - result_score_for_white
  end
end
