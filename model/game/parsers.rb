module NBA
  class Game < ActiveRecord::Base
    module Parsers
      IGNORE_PLAYERS = [100686, 203191, 203156]
      # need the players to correlate with the pbp
      # note that the pbp only uses last name to identify players, so teams with players
      # sharing a last name are ambiguously referenced.  I'm looking at you, Morris twins.
      #def parse_boxscore
      #  @player_map = {}
      #  boxscore = @boxscore if boxscore.nil?

      #  # find out who is home/away
      #  home_away = parse_game_summary(boxscore)
      #  # generate player map
      #  @player_map = parse_player_list(boxscore, home_away)
      #end

      def game_summary_parser
        @boxscore ||= read_cached_file(boxscore_cache_path)
        puts "parsing game summary, #{boxscore_cache_path}"
        summary = find_named_result_set(@boxscore, 'GameSummary')
        headers = summary['headers']
        summary_hash = array_into_hash(summary['rowSet'][0], headers)

        self.home_team = Team.find(summary_hash[:home_team_id])
        self.away_team = Team.find summary_hash[:visitor_team_id]
        self.season = summary_hash[:season]
      end

      def linescore_parser
        game_summary_parser unless self.home_team
        linescore = find_named_result_set(@boxscore, 'LineScore')
        headers = linescore['headers']
        linescore['rowSet'].each do |line|
          team = array_into_hash(line, headers)
          self.date = date_to_unixtime team[:game_date_est]
          team[:team_id] == home_team.id ?
            self.home_score = team[:pts] :
            self.away_score = team[:pts]
        end
      end

      def player_list_parser
        game_summary_parser unless self.home_team
        players = { home: {}, away: {} }
        player_box = find_named_result_set(@boxscore, 'PlayerStats')
        headers = player_box['headers']

        player_box['rowSet'].each do |p|
          p = array_into_hash(p, headers)
          # josh akognon, nba error
          unless IGNORE_PLAYERS.include? p[:player_id]
            team_id = p[:team_id]
            home_or_away = home_team.id == team_id ? :home : :away
            # base import, does not dig down and import player shots
            player = Player.find_or_import(p[:player_id]) 

            # Guessing the hueristic for Nene's display name...
            display_name = 
              ( player.display_first_last == player.first_name + ' ' +player.last_name ) ?
              player.last_name : player.display_first_last

            players[home_or_away][display_name] = player
          end
        end

        @players = players
      end

      def play_by_play_parser
        game_summary_parser unless @players
        json = read_cached_file(pbp_cache_path)
        json = find_named_result_set(json, 'PlayByPlay')

        headers = json['headers']
        # juggle score, since I'm more interested in differential at the moment
        # of the shot, not the actual score
        last_score = '0 - 0'
        json['rowSet'].each do |event_array|
          event_hash = array_into_hash(event_array, headers, GameEvent::KEY_MAP)
          score = event_hash[:score] || last_score
          event_hash[:score] = last_score
          GameEvent.find_or_import(event_hash)
          last_score = score
        end
      end
    end
  end
end
