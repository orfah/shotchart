class Shotchart < Sinatra::Base
  register Sinatra::Namespace
  namespace '/team' do
    get('/all') { send_all_teams }

    get('/:id/shotchart/against') { send_shotchart_against(params[:id]) }
    get('/:id/shotchart') { send_shotchart_for(params[:id]) }

    # unnecessary?
    #get('/:id') { send_team(params[:id]) }
  end

  def send_all_teams
    NBA::Team.find(:all, :order => :city).collect { |t| t.attributes }.to_json
  end

  def send_shotchart_against(team_id)
    send_shotchart(team_id, true)
  end

  def send_shotchart_for(team_id)
    send_shotchart(team_id)
  end

  def send_shotchart(team_id, against=false)
    against_or_for = against ? :team_against : :team_for
    shots = NBA::Shot.where(against_or_for => team_id).collect do |shot|
      shot.attributes
    end
    shots.to_json
  end
end
