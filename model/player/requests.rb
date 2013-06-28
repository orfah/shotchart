module NBA
  class Player < ActiveRecord::Base
    module Requests
      def player_url
        "http://stats.nba.com/stats/commonplayerinfo/?PlayerID=#{id}&SeasonType=Regular+Season"
      end

      def profile_url
        "http://stats.nba.com/feeds/players/profile/#{id}_Profile.js"
      end

      def awards_url
        "http://stats.nba.com/feeds/players/awards/#{id}_Award.js"
      end

      def shot_url(year)
        next_year_postfix = (year + 1).to_s[2,3]
        "http://stats.nba.com/stats/shotchartdetail?" +
          "Season=#{year}-#{next_year_postfix}" + 
        "&PlayerID=#{id}" + 

        "&SeasonType=Regular+Season&TeamID=0&GameID=&Outcome=&Location=&Month=0&SeasonSegment=&DateFrom=&DateTo=&OpponentTeamID=0&VsConference=&VsDivision=&Position=&RookieYear=&GameSegment=&Period=0&LastNGames=0&ContextFilter=&ContextMeasure=FG_PCT"
      end

      # player includes the name
      def player_multi_handle(options={})
        # forbid_reuse b/c of this: https://github.com/typhoeus/typhoeus/issues/238
        request(player_url, player_cache_path, options)
      end

      # profile has the height/weight. why two urls, nba?  WHYYYYYYYY
      def profile_multi_handle(options={})
        # http://stats.nba.com/feeds/players/profile/951_Profile.js
        # doesn't include name? wtf?
        request(profile_url, profile_cache_path, options)
      end

      def awards_multi_handle(options={})
        request(awards_url, awards_cache_path, options)
      end

      def shot_multi_handle(options={})
        year = options[:year] || Date.today.year - 1
        request(shot_url(year), shot_cache_path(year), options)
      end
    end
  end
end

