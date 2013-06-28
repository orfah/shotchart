module NBA
  class Game < ActiveRecord::Base
    module Requests
      def pbp_url
        # play by play
        "http://stats.nba.com/stats/playbyplay?GameID=#{id}&StartPeriod=0&EndPeriod=0"
      end

      def boxscore_url
        "http://stats.nba.com/stats/boxscore?GameID=#{id}&RangeType=0&StartPeriod=0&EndPeriod=0&StartRange=0&EndRange=0"
      end

      def pbp_multi_handle(options={})
        request = Typhoeus::Request.new(pbp_url, options)
      end

      def boxscore_multi_handle(options={})
        request = Typhoeus::Request.new(boxscore_url, options)
      end
    end
  end
end
