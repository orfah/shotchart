require_relative 'utilities/requests'
require_relative 'utilities/cache'
require_relative 'utilities/parsers'

require_relative 'game/requests'
require_relative 'game/cache'
require_relative 'game/parsers'

module NBA
  class Game
    include NBA::Requests
    include NBA::Cache
    include NBA::Parsers

    include Game::Requests
    include Game::Cache
    include Game::Parsers

    has_many :shots
    has_many :game_events
    alias_method :events, :game_events

    belongs_to :home_team, :class_name => "Team"#, :foreign_key => :team_id
    belongs_to :away_team, :class_name => "Team"#, :foreign_key => :team_id

    # designated initializer
    def self.find_or_import(game_id)
      game = self.find_by_id(game_id)
      if game.nil?
        game = self.new
        game.id = game_id
        # i've got all the games already, don't do this
        #game.fetch(game_id)
      end

      game.methods.grep(/.*_parse/).each do |parser|
        game.send(parser)
      end

      game.save if game.new_record?
      game
    end

    def player_team(player_id)

    end

    def team_against(player_id)

    end

  end

end
