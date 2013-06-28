module NBA
  class Player < ActiveRecord::Base
    module Parsers
      def parse(options={})
        methods.grep(/.*_parse/).each do |parser|
          send(parser, options)
        end
      end

      def player_parser(options={})
        @profile ||= {}
        json = read_cached_file(player_cache_path)
        json['resultSets'][0]['headers'].each_with_index do |header, index|
          @profile[header] = json['resultSets'][0]['rowSet'][0][index]
        end
      end

      def profile_parser(options={})
        @profile ||= {}
        json = read_cached_file(profile_cache_path)
        json['PlayerProfile'].each do |profile_section|
          if profile_section.has_key? 'PlayerBio'
            # who has multiple player bios? Not even Bison Dele...
            @profile.merge! profile_section['PlayerBio'][0]
          elsif (profile_section.has_key? 'PlayerTeamSeasons') 
            @profile['teams'] = profile_section['PlayerTeamSeasons']
          end
        end
      end

      def awards_parser(options={})
        @profile ||= {}
        json = read_cached_file(awards_cache_path)
        @profile['awards'] = json['PlayerAwards']
        rescue 
          # no awards for this loser
      end

      def shot_parser(options={})
        # flag to short-circuit shot parser, so we don't spiral from player to game to
        # player, etc. Allows us to just import strict player data.
        if options[:parse_all]
          year = options[:year] || Date.today.year - 1
          json = read_cached_file(shot_cache_path(year))
          shot_chart = []

          headers = json['resultSets'][0]['headers']
          last_game_id = nil
          json['resultSets'][0]['rowSet'].each do |shot_array|
            shot_hash = array_into_hash(shot_array, headers)
            game_id = shot_hash[:game_id]
            game = Game.find_or_import(shot_hash[:game_id]) if last_game_id != game_id
            shot = Shot.initialize_with_hash(shot_hash)
            last_game_id = game_id
          end
        end
      end

    end
  end
end
