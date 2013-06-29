require 'pp'
class Shotchart < Sinatra::Base
  register Sinatra::Namespace
  namespace '/player' do

    get('/search/:name') { search(params[:name]) }

    get('/:id/shots/against/:team_id') { send_shots_against(params[:id], params[:team_id]) }
    get('/:id/shots/period/:period')   { send_shots_by_period(params[:id], params[:period]) }
    get('/:id/shots/type/:type')   { send_shots_by_type(params[:id], params[:type]) }
    get('/:id/shots/clutch') { send_shots_clutch(params[:id], params[:team_id]) }
    get('/:id/shots') { send_shots(params[:id]) }

    get('/:id') { send_player(params[:id]) }


    def search(name)
      name_wildcard = name + '%'
      players = NBA::Player.where('first_name like ? OR last_name like ?', 
                                  name_wildcard, name_wildcard).order('first_name asc',
                                                                      'rookie_year desc')
      players.collect! { |p| p.to_hash }
      players.to_json
    end

    def send_player(player_id)
      NBA::Player.find(player_id).to_hash.to_json
    end

    def send_filtered_shots(player_id, filters=[])
      s = NBA::Shot.new
      filters.each do |f|
        if s.respond_to?(f)

        end
      end
    end

    def send_shots(player_id)
      find_shots(player_id).to_json
    end

    # consider a more meta way to generate these...
    def send_shots_against(player_id, team_id)
      find_shots(player_id, { :team_against => team_id }).to_json
    end

    def send_shots_clutch(player_id, team_id)
      find_shots(player_id, {period:4, time_remaining: 0..300, differential:0..5}).to_json
    end

    def send_shots_by_period(player_id, period)
      find_shots(player_id, { :period => period }).to_json
    end

    def find_shots(player_id, params=nil)
      pp params
      shots = NBA::Player.find(player_id).shots
      shots = shots.where(params) if params
      shots.collect {|s| s.attributes }
    end
  end
end
